//
//  MenuCategories.swift
//  Stampy
//
//  Single source of truth for Menu tab categories (Firestore field: menuCategory).
//

import Foundation

enum MenuCategories {
    static let all: [String] = [
        "Rubbers",
        "Inks",
        "Paris stamps",
        "Envelopes",
        "Ancient stamps",
        "Papers"
    ]

    /// Older catalog rows used these spellings. They still belong to the corrected name.
    private static let aliases: [String: Set<String>] = [
        "envelopes": ["envelopes", "envelops"],
        "ancient stamps": ["ancient stamps", "antient stamps"]
    ]

    static func displayName(for stored: String) -> String {
        switch stored.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "envelops", "envelopes":
            return "Envelopes"
        case "antient stamps", "ancient stamps":
            return "Ancient stamps"
        default:
            return stored.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func matches(_ stored: String?, category: String) -> Bool {
        let storedKey = stored?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        guard !storedKey.isEmpty else { return false }
        let wanted = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if storedKey == wanted { return true }
        return aliases[wanted]?.contains(storedKey) == true
    }
}
