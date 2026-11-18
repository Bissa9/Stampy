//
//  OrderItem.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 14/12/2025.
//

import Foundation

struct OrderItem: Identifiable, Codable {
    let id: String           // stampId
    let name: String
    let imageURL: String?
    let price: Double
    let quantity: Int
}
