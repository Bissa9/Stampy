//
//  Stamp.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth


struct Stamp: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String?
    var country: String?
    var year: Int?
    var price: Double?
    var imageURL: String?
    var category: String?
    /// Matches a label from `MenuCategories` (stored in Firestore as `menuCategory`).
    var menuCategory: String?
    var ownerId: String?
    var tags: [String]? 
    var createdAt: Timestamp?
    var quantity: Int = 1
    
    // Convenience initializer for general use + previews
    init(
        id: String? = nil,
        name: String,
        description: String? = nil,
        country: String? = nil,
        year: Int? = nil,
        price: Double? = nil,
        imageURL: String? = nil,
        category: String? = nil,
        menuCategory: String? = nil,
        ownerId: String? = nil,
        tags: [String]? = nil,
        createdAt: Timestamp? = nil,
        quantity: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.country = country
        self.year = year
        self.price = price
        self.imageURL = imageURL
        self.category = category
        self.menuCategory = menuCategory
        self.ownerId = ownerId
        self.tags = tags
        self.createdAt = createdAt
        self.quantity = quantity
    }
    
    // Shorter initializer commonly used in previews
    init(
        id: String? = nil,
        name: String,
        description: String? = nil,
        price: Double,
        quantity: Int = 1,
        imageURL: String? = nil
    ) {
        self.init(
            id: id,
            name: name,
            description: description,
            country: nil,
            year: nil,
            price: price,
            imageURL: imageURL,
            category: nil,
            menuCategory: nil,
            ownerId: nil,
            tags: nil,
            createdAt: nil,
            quantity: quantity
        )
    }
}
