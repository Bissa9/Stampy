import SwiftUI
import FirebaseAuth
import StripePaymentSheet

struct CheckoutPaymentMethodView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel

    let onComplete: (String, OrderPaymentMethod) -> Void
    var directCheckoutItems: [Stamp]? = nil

    @State private var isBusy = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var checkoutSnapshot: [Stamp] = []
    @State private var showCardDetails = false

    private let orderService = OrderService()
    private let stripeBackend = StripePaymentBackendService()

    var body: some View {
        VStack(spacing: 24) {
            Text("How would you like to pay?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Order summary")
                    .font(.headline)
                ForEach(checkoutSnapshot) { item in
                    HStack {
                        Text(item.name)
                            .lineLimit(1)
                        Spacer()
                        Text(itemPriceText(for: item))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )

            Text("Total: $\(snapshotTotal, specifier: "%.2f")")
                .font(.headline)
                .foregroundStyle(.secondary)

            paymentOptionCard(
                title: "Credit or debit card",
                subtitle: "Pay securely with Stripe",
                systemImage: "creditcard.fill",
                action: { showCardDetails = true }
            )

            paymentOptionCard(
                title: "Cash on delivery",
                subtitle: "Pay when your stamps arrive",
                systemImage: "banknote.fill",
                action: { Task { await payWithCash() } }
            )

            Spacer()
        }
        .padding()
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isBusy)
        .overlay {
            if isBusy {
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
        .alert("Payment", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            if checkoutSnapshot.isEmpty {
                checkoutSnapshot = directCheckoutItems ?? cartVM.items
            }
        }
        .navigationDestination(isPresented: $showCardDetails) {
            CardDetailsView(
                isProcessing: isBusy,
                onPayNow: { Task { await payWithCard() } }
            )
        }
    }

    @ViewBuilder
    private func paymentOptionCard(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(StampyTheme.ink)
                    .frame(width: 44, height: 44)
                    .background(StampyTheme.ink.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }

    private func payWithCash() async {
        guard let buyerId = authVM.currentUser?.id else {
            presentError("You need to be logged in.")
            return
        }
        guard !checkoutSnapshot.isEmpty else {
            presentError("Your checkout is empty. Please go back and add items.")
            return
        }

        isBusy = true
        defer { isBusy = false }

        do {
            let orderId = try await orderService.createOrder(
                from: checkoutSnapshot,
                buyerId: buyerId,
                paymentMethod: OrderPaymentMethod.cash
            )
            await MainActor.run {
                cartVM.recordPurchased(checkoutSnapshot)
                if directCheckoutItems == nil {
                    cartVM.clear()
                }
            }
            await authVM.recordPayment(amount: snapshotTotal)
            // Push success route after cart mutation to avoid navigation race conditions.
            await MainActor.run {
                DispatchQueue.main.async {
                    onComplete(orderId, .cash)
                }
            }
        } catch {
            presentError(error.localizedDescription)
        }
    }

    private func payWithCard() async {
        guard StripeConfig.isPublishableKeyConfigured else {
            presentError("Card payments need a Stripe publishable key in Config/Secrets.xcconfig. Rebuild after you add it.")
            return
        }
        guard let buyerId = authVM.currentUser?.id else {
            presentError("You need to be logged in.")
            return
        }
        guard let firebaseUser = Auth.auth().currentUser else {
            presentError("Your session expired. Please sign out and sign in again, then try paying with a card.")
            return
        }
        guard firebaseUser.uid == buyerId else {
            presentError("Account mismatch. Please sign out and sign in again.")
            return
        }
        guard !checkoutSnapshot.isEmpty else {
            presentError("Your checkout is empty. Please go back and add items.")
            return
        }

        isBusy = true
        do {
            let orderId = try await orderService.createOrder(
                from: checkoutSnapshot,
                buyerId: buyerId,
                paymentMethod: OrderPaymentMethod.card
            )
            // Brief pause so Firestore is visible to Cloud Functions before the HTTP follow-up.
            try await Task.sleep(nanoseconds: 500_000_000)
            let clientSecret = try await stripeBackend.createPaymentIntent(orderId: orderId)

            await MainActor.run {
                isBusy = false
                PaymentSheetPresenter.presentPaymentSheet(clientSecret: clientSecret) { result in
                    Task {
                        await handleCardResult(result, orderId: orderId)
                    }
                }
            }
        } catch {
            await MainActor.run { isBusy = false }
            presentError(error.localizedDescription)
        }
    }

    private func handleCardResult(_ result: PaymentSheetResult, orderId: String) async {
        switch result {
        case .completed:
            do {
                try await orderService.markOrderPaid(orderId: orderId)
                await authVM.recordPayment(amount: snapshotTotal)
                await MainActor.run {
                    cartVM.recordPurchased(checkoutSnapshot)
                    if directCheckoutItems == nil {
                        cartVM.clear()
                    }
                    onComplete(orderId, .card)
                }
            } catch {
                presentError(error.localizedDescription)
            }
        case .canceled:
            break
        case .failed(let error):
            presentError(error.localizedDescription)
        }
    }

    private func presentError(_ message: String) {
        Task { @MainActor in
            errorMessage = message
            showError = true
        }
    }

    private var snapshotTotal: Double {
        checkoutSnapshot.reduce(0) { $0 + (Double($1.quantity) * ($1.price ?? 0)) }
    }

    private func itemPriceText(for item: Stamp) -> String {
        let unit = item.price ?? 0
        let subtotal = unit * Double(item.quantity)
        if item.quantity > 1 {
            return String(format: "$%.2f × %d = $%.2f", unit, item.quantity, subtotal)
        }
        return String(format: "$%.2f", subtotal)
    }
}

#Preview {
    
}
