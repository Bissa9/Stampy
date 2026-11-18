//
//  StampService.swift
//  Stampy
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

enum StampServiceError: LocalizedError {
    case missingName
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Enter a name for this stamp."
        case .notSignedIn:
            return "Sign in before uploading a stamp."
        }
    }
}

struct StampService {
    private let db = Firestore.firestore()
    private let images = ImageService()

    func fetchStamps() async throws -> [Stamp] {
        // Ordering in Firestore hides every stamp that has no createdAt field.
        // Older catalog rows are read here and sorted on the device instead.
        let snapshot = try await db.collection("stamps").getDocuments()
        return snapshot.documents.compactMap(stamp(from:)).sorted { lhs, rhs in
            let left = lhs.createdAt?.dateValue() ?? .distantPast
            let right = rhs.createdAt?.dateValue() ?? .distantPast
            if left == right {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return left > right
        }
    }

    private func stamp(from document: QueryDocumentSnapshot) -> Stamp? {
        let data = document.data()
        guard let name = text(data["name"]) ?? text(data["title"]) else {
            return nil
        }

        let category = text(data["category"])
        let menuCategory = text(data["menuCategory"]) ?? category
        return Stamp(
            id: document.documentID,
            name: name,
            description: text(data["description"]),
            country: text(data["country"]),
            year: intValue(data["year"]),
            price: doubleValue(data["price"]),
            imageURL: text(data["imageURL"]) ?? text(data["imageUrl"]) ?? text(data["image"]),
            category: category ?? menuCategory,
            menuCategory: menuCategory,
            ownerId: text(data["ownerId"]),
            tags: stringList(data["tags"]),
            createdAt: timestamp(data["createdAt"]),
            quantity: intValue(data["quantity"]) ?? 1
        )
    }

    private func text(_ value: Any?) -> String? {
        guard let raw = value as? String else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func doubleValue(_ value: Any?) -> Double? {
        switch value {
        case let number as NSNumber:
            return number.doubleValue
        case let string as String:
            return Double(string.replacingOccurrences(of: "$", with: ""))
        default:
            return nil
        }
    }

    private func intValue(_ value: Any?) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let string as String:
            return Int(string)
        default:
            return nil
        }
    }

    private func stringList(_ value: Any?) -> [String]? {
        if let list = value as? [String] {
            let cleaned = list.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            return cleaned.isEmpty ? nil : cleaned
        }
        if let one = text(value) {
            return [one]
        }
        return nil
    }

    private func timestamp(_ value: Any?) -> Timestamp? {
        switch value {
        case let stamp as Timestamp:
            return stamp
        case let date as Date:
            return Timestamp(date: date)
        case let number as NSNumber:
            return Timestamp(date: Date(timeIntervalSince1970: number.doubleValue))
        default:
            return nil
        }
    }

    func uploadStamp(image: UIImage, name: String, description: String?, menuCategory: String?) async throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw StampServiceError.missingName
        }
        guard let ownerId = Auth.auth().currentUser?.uid else {
            throw StampServiceError.notSignedIn
        }

        let ref = db.collection("stamps").document()
        let stampId = ref.documentID
        let url = try await images.uploadJPEG(image, path: "stamps/\(stampId)/photo.jpg")
        let trimmedDescription = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let storedDescription = (trimmedDescription?.isEmpty == false) ? trimmedDescription : nil

        let stamp = Stamp(
            id: stampId,
            name: trimmedName,
            description: storedDescription,
            country: nil,
            year: nil,
            price: nil,
            imageURL: url.absoluteString,
            category: menuCategory,
            menuCategory: menuCategory,
            ownerId: ownerId,
            tags: [],
            createdAt: Timestamp(date: Date()),
            quantity: 1
        )

        try ref.setData(from: stamp)
    }
}
