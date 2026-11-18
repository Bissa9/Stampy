//
//  Order.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import Foundation
import FirebaseFirestore


struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    
    let buyerId: String
    let sellerId: String
    let items: [OrderItem]
    let totalPrice: Double
    let status: OrderStatus
    
    /// "card" or "cash" — used by Cloud Functions for card flow.
    let paymentMethod: String
    /// Set after PaymentIntent is created on the server.
    let stripePaymentIntentId: String?
    
    let createdAt: Timestamp
    let updatedAt: Timestamp?
    let shippingAddress: String?
    let notes: String?
}
