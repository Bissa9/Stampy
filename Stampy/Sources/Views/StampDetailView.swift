//
//  StampDetailView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import SwiftUI
import UIKit

private struct StampDetailSuccessFlow: View {
    let orderId: String
    let method: OrderPaymentMethod

    @Environment(\.dismiss) private var dismiss
    @State private var showTrack = false

    var body: some View {
        PaymentSuccessView(
            orderId: orderId,
            title: method == .cash ? "Your order is coming soon" : "Payment success",
            onTrack: { showTrack = true },
            onBackHome: { dismiss() }
        )
        .navigationDestination(isPresented: $showTrack) {
            TrackOrderView(orderId: orderId)
        }
    }
}

private struct StampDetailCompletedOrder: Identifiable {
    let id = UUID()
    let orderId: String
    let method: OrderPaymentMethod
}

struct StampDetailView: View {
    let stamp: Stamp
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showAddedToast = false
    @State private var showBuyNowCheckout = false
    @State private var completedOrder: StampDetailCompletedOrder?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Buttons live outside ScrollView so taps aren’t eaten by scroll gestures.
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: URL(string: stamp.imageURL ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(16)
                            case .failure(_):
                                Color.gray.opacity(0.3)
                                    .frame(height: 250)
                            default:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 250)
                            }
                        }

                        HStack(spacing: 12) {
                            Text(stamp.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                cartVM.toggleFavorite(stamp)
                            } label: {
                                Image(systemName: cartVM.isFavorite(stamp) ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundStyle(cartVM.isFavorite(stamp) ? StampyTheme.ink : Color.gray)
                            }
                            .buttonStyle(.plain)
                        }

                        if let description = stamp.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        if let price = stamp.price {
                            Text("$\(price, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(StampyTheme.ink)
                        }
                    }
                    .padding()
                    .padding(.bottom, 8)
                }

                VStack(spacing: 12) {
                    Button {
                        cartVM.addItem(stamp)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            showAddedToast = true
                        }
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation(.easeOut(duration: 0.28)) {
                                showAddedToast = false
                            }
                        }
                    } label: {
                        Text("Add to Cart")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PurplePressButtonStyle())

                    Button {
                        showBuyNowCheckout = true
                    } label: {
                        Text("Buy Now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(StampyTheme.ink, lineWidth: 1)
                            )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }

            if showAddedToast {
                Text("1 item added to the cart")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.88))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    .padding(.bottom, 120)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showBuyNowCheckout) {
            NavigationStack {
                CheckoutPaymentMethodView(
                    onComplete: { orderId, method in
                        showBuyNowCheckout = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            completedOrder = StampDetailCompletedOrder(orderId: orderId, method: method)
                        }
                    },
                    directCheckoutItems: [buyNowStamp]
                )
                .environmentObject(cartVM)
                .environmentObject(authVM)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showBuyNowCheckout = false
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $completedOrder) { payload in
            NavigationStack {
                StampDetailSuccessFlow(orderId: payload.orderId, method: payload.method)
            }
        }
    }

    private var buyNowStamp: Stamp {
        var copy = stamp
        if copy.id == nil {
            copy.id = UUID().uuidString
        }
        copy.quantity = 1
        return copy
    }
}

#Preview {
    StampDetailView(
        stamp: Stamp(id: "1", name: "Vintage Stamp", description: "Rare stamp", price: 50, quantity: 1)
    )
    .environmentObject(CartViewModel())
    .environmentObject(AuthViewModel())
}
