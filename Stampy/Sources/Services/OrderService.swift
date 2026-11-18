import Foundation
import FirebaseFirestore


final class OrderService {
    private let db = Firestore.firestore()

    /// Creates an order document and returns its ID.
    @discardableResult
    func createOrder(
        from stamps: [Stamp],
        buyerId: String,
        paymentMethod: OrderPaymentMethod
    ) async throws -> String {
        guard !stamps.isEmpty else {
            throw NSError(
                domain: "OrderService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Cart is empty."]
            )
        }

        let items: [OrderItem] = stamps.compactMap { stamp in
            guard
                let id = stamp.id,
                let price = stamp.price
            else {
                return nil
            }

            return OrderItem(
                id: id,
                name: stamp.name,
                imageURL: stamp.imageURL,
                price: price,
                quantity: stamp.quantity
            )
        }

        guard !items.isEmpty else {
            throw NSError(
                domain: "OrderService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No priced items in cart."]
            )
        }

        let total = items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        let now = Timestamp(date: Date())
        let sellerId = stamps.first?.ownerId ?? "unknown"

        let order = Order(
            id: nil,
            buyerId: buyerId,
            sellerId: sellerId,
            items: items,
            totalPrice: total,
            status: .pending,
            paymentMethod: paymentMethod.rawValue,
            stripePaymentIntentId: nil,
            createdAt: now,
            updatedAt: nil,
            shippingAddress: nil,
            notes: nil
        )

        let ref = db.collection("orders").document()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try ref.setData(from: order) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
        return ref.documentID
    }

    func markOrderPaid(orderId: String) async throws {
        try await db.collection("orders").document(orderId).updateData([
            "status": OrderStatus.paid.rawValue,
            "updatedAt": Timestamp(date: Date()),
        ])
    }
}
