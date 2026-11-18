import SwiftUI
import FirebaseFirestore


struct TrackOrderView: View {
    let orderId: String

    @State private var order: Order?
    @State private var loadError: String?
    @State private var isLoading = true

    private let db = Firestore.firestore()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading order…")
            } else if let error = loadError {
                ContentUnavailableView(
                    "Couldn’t load order",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if let order {
                orderContent(order)
            }
        }
        .navigationTitle("Track order")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOrder()
        }
    }

    @ViewBuilder
    private func orderContent(_ order: Order) -> some View {
        List {
            Section("Status") {
                LabeledContent("State", value: order.status.rawValue.capitalized)
                LabeledContent(
                    "Total",
                    value: String(format: "$%.2f", order.totalPrice)
                )
                LabeledContent(
                    "Payment",
                    value: order.paymentMethod == OrderPaymentMethod.card.rawValue
                        ? "Card"
                        : "Cash on delivery"
                )
            }

            Section("Items") {
                ForEach(order.items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                        Text(
                            String(
                                format: "$%.2f each × %d",
                                item.price,
                                item.quantity
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Order ID") {
                Text(orderId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
    }

    private func loadOrder() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let snapshot = try await db.collection("orders").document(orderId).getDocument()
            order = try snapshot.data(as: Order.self)
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        TrackOrderView(orderId: "sample")
    }
}
