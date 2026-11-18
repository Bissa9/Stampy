"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

function getStripe() {
  const secret = functions.config().stripe && functions.config().stripe.secret;
  if (!secret) {
    throw new Error(
      "Stripe secret not configured. Run: firebase functions:config:set stripe.secret=\"sk_...\""
    );
  }
  // eslint-disable-next-line global-require
  return require("stripe")(secret);
}

/**
 * Brief read retries — rare propagation lag between client write and Cloud Function read.
 */
async function getOrderWithRetry(orderRef, orderId) {
  const delaysMs = [0, 200, 400, 800, 1600, 3200, 5000];
  for (const delay of delaysMs) {
    if (delay > 0) {
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
    const snap = await orderRef.get();
    if (snap.exists) {
      return snap;
    }
  }
  console.error("getOrderWithRetry: still missing after retries", orderId);
  throw new functions.https.HttpsError(
    "not-found",
    `Order not found for id ${orderId}. Confirm the app and Cloud Functions use the same Firebase project and database.`
  );
}

/**
 * Firebase HTTP handlers sometimes leave JSON in req.rawBody only — parse both.
 */
function readOrderIdFromRequest(req) {
  let obj = req.body;
  if (Buffer.isBuffer(obj)) {
    try {
      obj = JSON.parse(obj.toString("utf8"));
    } catch (_) {
      obj = null;
    }
  } else if (typeof obj === "string") {
    try {
      obj = JSON.parse(obj);
    } catch (_) {
      obj = null;
    }
  }
  if (obj && typeof obj === "object" && typeof obj.orderId === "string") {
    return obj.orderId.trim();
  }
  const raw = req.rawBody;
  if (Buffer.isBuffer(raw)) {
    try {
      const parsed = JSON.parse(raw.toString("utf8"));
      if (parsed && typeof parsed.orderId === "string") {
        return parsed.orderId.trim();
      }
    } catch (_) {
      /* ignore */
    }
  }
  return "";
}

/**
 * Core Stripe + Firestore logic (shared by callable and HTTP).
 */
async function runCreatePaymentIntent(uid, orderId) {
  if (!orderId) {
    throw new functions.https.HttpsError("invalid-argument", "orderId is required.");
  }

  const stripe = getStripe();
  const orderRef = admin.firestore().collection("orders").doc(orderId);
  const snap = await getOrderWithRetry(orderRef, orderId);

  const order = snap.data();
  if (!order) {
    throw new functions.https.HttpsError("not-found", "Order missing data.");
  }
  if (order.buyerId !== uid) {
    throw new functions.https.HttpsError("permission-denied", "Not your order.");
  }
  if (order.paymentMethod !== "card") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "This order is not using card payment."
    );
  }

  const amountCents = Math.round(Number(order.totalPrice) * 100);
  if (!Number.isFinite(amountCents) || amountCents < 50) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid order amount (minimum $0.50 for card payments)."
    );
  }

  const paymentIntent = await stripe.paymentIntents.create({
    amount: amountCents,
    currency: "usd",
    automatic_payment_methods: { enabled: true },
    metadata: {
      orderId,
      buyerId: uid,
    },
  });

  await orderRef.update({
    stripePaymentIntentId: paymentIntent.id,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { clientSecret: paymentIntent.client_secret };
}

/**
 * Resolves caller UID from callable context, or by verifying idToken in the body.
 */
async function resolveCallerUid(data, context) {
  if (context.auth && context.auth.uid) {
    return context.auth.uid;
  }
  const raw = typeof data.idToken === "string" ? data.idToken.trim() : "";
  if (!raw) {
    return null;
  }
  try {
    const decoded = await admin.auth().verifyIdToken(raw);
    return decoded.uid;
  } catch (e) {
    console.error("verifyIdToken failed:", e.message);
    return null;
  }
}

const region = "us-central1";

/**
 * Callable (optional): same logic; may still hit gateway auth issues on some setups.
 */
exports.createPaymentIntent = functions.region(region).https.onCall(async (data, context) => {
  const uid = await resolveCallerUid(data, context);
  if (!uid) {
    throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
  }
  const orderId = typeof data.orderId === "string" ? data.orderId : "";
  return runCreatePaymentIntent(uid, orderId);
});

/**
 * HTTP: iOS calls this with Authorization: Bearer <Firebase ID token>.
 * Bypasses the callable gateway (which can return UNAUTHENTICATED before your code runs).
 */
exports.createPaymentIntentHttp = functions.region(region).https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Authorization, Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const authHeader = req.get("Authorization") || "";
  const m = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!m) {
    return res.status(401).json({ error: "Missing Authorization Bearer token." });
  }

  let uid;
  try {
    const decoded = await admin.auth().verifyIdToken(m[1].trim());
    uid = decoded.uid;
  } catch (e) {
    console.error("Bearer verifyIdToken failed:", e.message);
    return res.status(401).json({ error: "Invalid or expired sign-in token." });
  }

  const orderId = readOrderIdFromRequest(req);
  if (!orderId) {
    console.error("createPaymentIntentHttp: missing orderId in body", {
      hasBody: !!req.body,
      bodyType: typeof req.body,
      hasRawBody: Buffer.isBuffer(req.rawBody),
    });
  }

  try {
    const result = await runCreatePaymentIntent(uid, orderId);
    return res.status(200).json(result);
  } catch (e) {
    if (e instanceof functions.https.HttpsError) {
      const map = {
        "invalid-argument": 400,
        "not-found": 404,
        "permission-denied": 403,
        "failed-precondition": 412,
        unauthenticated: 401,
      };
      const status = map[e.code] || 500;
      return res.status(status).json({ error: e.message });
    }
    console.error(e);
    return res.status(500).json({ error: "Payment could not start." });
  }
});

/**
 * HTTP webhook: mark order paid when Stripe confirms payment.
 */
exports.stripeWebhook = functions.region(region).https.onRequest(async (req, res) => {
  const stripe = getStripe();
  const whSecret =
    functions.config().stripe && functions.config().stripe.webhook_secret;

  if (!whSecret) {
    console.error("stripe.webhook_secret not set");
    return res.status(500).send("Webhook not configured");
  }

  const sig = req.headers["stripe-signature"];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, whSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === "payment_intent.succeeded") {
    const pi = event.data.object;
    const orderId = pi.metadata && pi.metadata.orderId;
    if (orderId) {
      await admin.firestore().collection("orders").doc(orderId).update({
        status: "paid",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  return res.json({ received: true });
});
