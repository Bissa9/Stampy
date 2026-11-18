//
//  CartViewModel.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import Foundation

final class CartViewModel: ObservableObject {
    @Published var items: [Stamp] = []
    @Published var favoriteStamps: [Stamp] = []
    @Published var purchasedStamps: [Stamp] = []

    private let itemsKey = "stampy.cart.items"
    private let favoritesKey = "stampy.cart.favorites"
    private let purchasedKey = "stampy.cart.purchased"
    private let storage = UserDefaults.standard

    init() {
        loadPersistedState()
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { partial, stamp in
            partial + (stamp.price ?? 0) * Double(stamp.quantity)
        }
    }

    func addItem(_ item: Stamp) {
        var item = item
        if item.id == nil {
            item.id = UUID().uuidString
        }
        guard let id = item.id else { return }

        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].quantity += 1
        } else {
            var newItem = item
            newItem.quantity = 1
            items.append(newItem)
        }
        persistState()
    }
    
    func removeItem(_ item: Stamp) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            persistState()
        }
    }
    
    func increaseQuantity(for item: Stamp) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].quantity += 1
        persistState()
    }
    
    func decreaseQuantity(for item: Stamp) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
        persistState()
    }
    
    func clear() {
        items.removeAll()
        persistState()
    }

    func isFavorite(_ stamp: Stamp) -> Bool {
        guard let id = stamp.id else { return false }
        return favoriteStamps.contains(where: { $0.id == id })
    }

    func toggleFavorite(_ stamp: Stamp) {
        guard let id = stamp.id else { return }
        if let index = favoriteStamps.firstIndex(where: { $0.id == id }) {
            favoriteStamps.remove(at: index)
        } else {
            var copy = stamp
            if copy.quantity <= 0 {
                copy.quantity = 1
            }
            favoriteStamps.append(copy)
        }
        persistState()
    }

    func recordPurchased(_ stamps: [Stamp]) {
        for stamp in stamps {
            guard let id = stamp.id else { continue }
            if let index = purchasedStamps.firstIndex(where: { $0.id == id }) {
                purchasedStamps[index].quantity += stamp.quantity
            } else {
                purchasedStamps.append(stamp)
            }
        }
        persistState()
    }

    private func persistState() {
        do {
            let encoder = JSONEncoder()
            let encodedItems = try encoder.encode(items.map(PersistedStamp.init))
            let encodedFavorites = try encoder.encode(favoriteStamps.map(PersistedStamp.init))
            let encodedPurchased = try encoder.encode(purchasedStamps.map(PersistedStamp.init))

            storage.set(encodedItems, forKey: itemsKey)
            storage.set(encodedFavorites, forKey: favoritesKey)
            storage.set(encodedPurchased, forKey: purchasedKey)
        } catch {
            print("Failed to persist cart state:", error.localizedDescription)
        }
    }

    private func loadPersistedState() {
        do {
            let decoder = JSONDecoder()

            if let data = storage.data(forKey: itemsKey) {
                let decoded = try decoder.decode([PersistedStamp].self, from: data)
                items = decoded.map(\.stamp)
            }

            if let data = storage.data(forKey: favoritesKey) {
                let decoded = try decoder.decode([PersistedStamp].self, from: data)
                favoriteStamps = decoded.map(\.stamp)
            }

            if let data = storage.data(forKey: purchasedKey) {
                let decoded = try decoder.decode([PersistedStamp].self, from: data)
                purchasedStamps = decoded.map(\.stamp)
            }
        } catch {
            print("Failed to load persisted cart state:", error.localizedDescription)
        }
    }
}

private struct PersistedStamp: Codable {
    let id: String?
    let name: String
    let description: String?
    let country: String?
    let year: Int?
    let price: Double?
    let imageURL: String?
    let category: String?
    let menuCategory: String?
    let ownerId: String?
    let tags: [String]?
    let quantity: Int

    init(_ stamp: Stamp) {
        id = stamp.id
        name = stamp.name
        description = stamp.description
        country = stamp.country
        year = stamp.year
        price = stamp.price
        imageURL = stamp.imageURL
        category = stamp.category
        menuCategory = stamp.menuCategory
        ownerId = stamp.ownerId
        tags = stamp.tags
        quantity = stamp.quantity
    }

    var stamp: Stamp {
        Stamp(
            id: id,
            name: name,
            description: description,
            country: country,
            year: year,
            price: price,
            imageURL: imageURL,
            category: category,
            menuCategory: menuCategory,
            ownerId: ownerId,
            tags: tags,
            createdAt: nil,
            quantity: quantity
        )
    }
}
