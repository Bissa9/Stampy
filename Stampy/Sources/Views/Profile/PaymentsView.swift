import SwiftUI
import FirebaseFirestore

struct PaymentsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var cartVM: CartViewModel
    let totalPayments: Double
    @State private var purchasedItems: [PurchasedPaymentItem] = []
    @State private var isLoading = false
    @State private var loadErrorMessage: String?

    private let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "creditcard.circle")
                    .font(.system(size: 38))
                    .foregroundStyle(StampyTheme.ink)

                Text("Total Payments")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(String(format: "$%.2f", totalPayments))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Purchased Items")
                        .font(.headline)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                    } else if let loadErrorMessage {
                        Text(loadErrorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if purchasedItems.isEmpty {
                        Text("No purchases yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(purchasedItems) { entry in
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: entry.imageURL ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        Color.gray.opacity(0.2)
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(2)
                                    Text(entry.dateText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 8)

                                Text(String(format: "$%.2f", entry.amount))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPurchasedItems()
        }
    }

    private func loadPurchasedItems() async {
        guard let uid = authVM.currentUser?.id else { return }
        isLoading = true
        loadErrorMessage = nil
        defer { isLoading = false }

        do {
            let snapshot = try await db.collection("orders")
                .whereField("buyerId", isEqualTo: uid)
                .getDocuments()

            var results: [(item: PurchasedPaymentItem, date: Date)] = []
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            for doc in snapshot.documents {
                let data = doc.data()
                guard let createdAt = data["createdAt"] as? Timestamp else { continue }
                let createdDate = createdAt.dateValue()
                let dateText = formatter.string(from: createdDate)
                let items = data["items"] as? [[String: Any]] ?? []

                for item in items {
                    let name = item["name"] as? String ?? "Stamp"
                    let imageURL = item["imageURL"] as? String
                    let quantity = item["quantity"] as? Int ?? 1
                    let price: Double = {
                        if let p = item["price"] as? Double { return p }
                        if let p = item["price"] as? NSNumber { return p.doubleValue }
                        if let p = item["price"] as? Int { return Double(p) }
                        return 0
                    }()

                    results.append(
                        (
                            PurchasedPaymentItem(
                            name: name,
                            imageURL: imageURL,
                            dateText: dateText,
                            amount: price * Double(quantity)
                            ),
                            createdDate
                        )
                    )
                }
            }

            purchasedItems = results
                .sorted(by: { $0.date > $1.date })
                .map(\.item)

            // Local fallback so user still sees purchases if Firestore is empty/new.
            if purchasedItems.isEmpty {
                purchasedItems = cartVM.purchasedStamps.map {
                    PurchasedPaymentItem(
                        name: $0.name,
                        imageURL: $0.imageURL,
                        dateText: "Recently purchased",
                        amount: ($0.price ?? 0) * Double($0.quantity)
                    )
                }
            }
        } catch {
            loadErrorMessage = "Could not load from server yet. Showing local purchases."
            purchasedItems = cartVM.purchasedStamps.map {
                PurchasedPaymentItem(
                    name: $0.name,
                    imageURL: $0.imageURL,
                    dateText: "Recently purchased",
                    amount: ($0.price ?? 0) * Double($0.quantity)
                )
            }
        }
    }
}

private struct PurchasedPaymentItem: Identifiable {
    let id = UUID()
    let name: String
    let imageURL: String?
    let dateText: String
    let amount: Double
}

#Preview {
    NavigationStack {
        PaymentsView(totalPayments: 125.50)
            .environmentObject(AuthViewModel())
            .environmentObject(CartViewModel())
    }
}
