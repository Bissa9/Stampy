//
//  CartView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 21/02/2026.
//

import SwiftUI

/// Shown after checkout completes; keeps success + track in one stack (no nested stack vs Home).
private struct SuccessAndTrackFlow: View {
    let orderId: String
    let method: OrderPaymentMethod
    let onBackHome: () -> Void

    @State private var showTrack = false

    var body: some View {
        PaymentSuccessView(
            orderId: orderId,
            title: method == .cash ? "Your order is coming soon" : "Payment success",
            onTrack: { showTrack = true },
            onBackHome: onBackHome
        )
        .navigationDestination(isPresented: $showTrack) {
            TrackOrderView(orderId: orderId)
        }
    }
}

private struct CompletedOrderPayload: Identifiable, Equatable {
    let id = UUID()
    let orderId: String
    let method: OrderPaymentMethod
}

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showCheckoutOptions = false
    @State private var completedOrder: CompletedOrderPayload?

    var body: some View {
        Group {
            if cartVM.items.isEmpty {
                emptyCartPlaceholder
            } else {
                cartListWithCheckout
            }
        }
        .navigationTitle("Cart")
        // Full-screen checkout avoids SwiftUI freezes from navigationDestination + List + safeAreaInset.
        .fullScreenCover(isPresented: $showCheckoutOptions) {
            NavigationStack {
                CheckoutPaymentMethodView { orderId, method in
                    showCheckoutOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        completedOrder = CompletedOrderPayload(orderId: orderId, method: method)
                    }
                }
                .environmentObject(cartVM)
                .environmentObject(authVM)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showCheckoutOptions = false
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $completedOrder) { payload in
            NavigationStack {
                SuccessAndTrackFlow(
                    orderId: payload.orderId,
                    method: payload.method,
                    onBackHome: {
                        completedOrder = nil
                        dismiss()
                    }
                )
            }
        }
    }

    private var emptyCartPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(StampyTheme.ink)
            Text("Your cart is empty")
                .font(.headline)
            Text("Stamps you add show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(StampyTheme.paper)
    }

    private var cartListWithCheckout: some View {
        List {
            ForEach(cartVM.items.indices, id: \.self) { index in
                let stamp = cartVM.items[index]
                CartItemBox(
                    stamp: stamp,
                    onIncrease: { cartVM.increaseQuantity(for: stamp) },
                    onDecrease: { cartVM.decreaseQuantity(for: stamp) }
                )
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text("$\(cartVM.totalPrice, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(StampyTheme.ink)
                }

                Button {
                    showCheckoutOptions = true
                } label: {
                    Text("Checkout")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .foregroundColor(.white)
                }
                .buttonStyle(PurplePressButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = cartVM.items[index]
            cartVM.removeItem(item)
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
        .environmentObject(AuthViewModel())
}
