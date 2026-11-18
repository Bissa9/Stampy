//
//  OrderStatus.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 14/12/2025.
//

import Foundation

enum OrderStatus: String, Codable {
    case pending     // created but not paid
    case paid        // payment done
    case shipped     // seller shipped
    case delivered   // buyer received
    case cancelled
}
