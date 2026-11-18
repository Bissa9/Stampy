# Stampy

<img width="439" height="956" alt="Screenshot 2026-11-18 at 5 35 16 AM" src="https://github.com/user-attachments/assets/3a74f11f-6833-4a48-888d-0cd417789304" />
<img width="429" height="886" alt="Screenshot 2026-11-18 at 5 29 27 AM" src="https://github.com/user-attachments/assets/be0222ed-3d03-4eaa-98e0-ab1cbaed12a4" />
<img width="439" height="956" alt="Screenshot 2026-11-18 at 5 30 35 AM" src="https://github.com/user-attachments/assets/c807f0ef-4953-4e3c-8097-64d809d6662e" />
<img width="439" height="956" alt="Screenshot 2026-11-18 at 5 30 15 AM" src="https://github.com/user-attachments/assets/64dc47ba-bcf9-473c-bb00-bba77619c0fc" />
<img width="439" height="956" alt="Screenshot 2026-11-18 at 5 29 57 AM" src="https://github.com/user-attachments/assets/694d9c7c-d58e-457c-9309-a7d5a836655b" />



SwiftUI catalog for postage stamps. Sign in with Firebase, browse the catalog, keep a cart, and check out with cash or a Stripe card payment.

## What a reviewer will see

- SwiftUI screens split into views, view models, and services
- Firebase Authentication, Firestore, and Storage
- Stripe PaymentSheet, with the amount taken from the order on the server
- Firestore rules that let a signed-in user write only their own stamps and orders
- An ink-and-paper look: app icon, launch screen, sign-in, catalog, and menu

Sign-in shows the error from Firebase instead of failing quietly. The catalog shows a loading state and a retry if the stamps cannot be fetched. Category names in the app are **Envelopes** and **Ancient stamps**. Older catalog rows saved as `Envelops` or `Antient stamps` still appear under those names.

## Run it

1. Open `Stampy.xcodeproj` in Xcode 16 or newer. The iOS deployment target is 18.2.
2. Download `GoogleService-Info.plist` from the Firebase project `stampy-90571` for bundle id `myPlayground.swift.Stampy`.
3. Put that file in the `Stampy` folder, next to `Assets.xcassets`. It is gitignored.
4. Copy `Config/Secrets.example.xcconfig` to `Config/Secrets.xcconfig` and set `STRIPE_PUBLISHABLE_KEY` to the publishable key from the same Stripe account as the Cloud Functions secret.
5. Select the shared **Stampy** scheme and run.

The bundle id stays `myPlayground.swift.Stampy` because that is the id registered in Firebase. Changing it needs a new iOS app in the Firebase console and a new plist.

Without the plist, the app opens a setup screen instead of crashing. Card checkout stays disabled until `Secrets.xcconfig` has a real `pk_` key.

## Backend

Cloud Functions live in `functions/`. Stripe secret keys are set with `firebase functions:config:set` and are not in this repository. Payment flow details are in `docs/stripe-firebase.md`.

Deploy rules after you pull this version:

```bash
firebase deploy --only firestore:rules --project stampy-90571
```

The updated rules allow the catalog to be read publicly, and allow stamp creates, updates, and deletes only when `ownerId` is the signed-in user.
