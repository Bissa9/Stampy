//
//  AuthService.swift
//  Stampy
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthServiceError: LocalizedError {
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "You need to be signed in."
        }
    }
}

struct AuthService {
    /// Resolved on use so the app can launch before `FirebaseApp.configure()`.
    private var db: Firestore { Firestore.firestore() }

    var currentAuthUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func createUser(email: String, password: String, fullname: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = User(id: result.user.uid, fullname: fullname, email: email, paymentsTotal: 0, balance: 0)
        try await uploadUserData(user)
        return try await fetchUser() ?? user
    }

    func fetchUser() async throws -> User? {
        guard let session = currentAuthUser else { return nil }
        let snapshot = try await db.collection("users").document(session.uid).getDocument()

        if let data = snapshot.data() {
            let fullname = data["fullname"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let paymentsTotal = numberValue(data["paymentsTotal"]) ?? 0
            let balance = numberValue(data["balance"]) ?? 0
            let normalizedName = resolvedFullname(
                preferredName: fullname,
                authUser: session,
                email: email
            )
            let resolvedEmail = email.isEmpty ? (session.email ?? "") : email
            let resolvedUser = User(
                id: snapshot.documentID,
                fullname: normalizedName,
                email: resolvedEmail,
                paymentsTotal: paymentsTotal,
                balance: balance
            )
            if normalizedName != fullname || resolvedEmail != email {
                try await uploadUserData(resolvedUser)
            }
            return resolvedUser
        }

        let recoveredUser = User(
            id: session.uid,
            fullname: resolvedFullname(
                preferredName: session.displayName ?? "",
                authUser: session,
                email: session.email ?? ""
            ),
            email: session.email ?? "",
            paymentsTotal: 0,
            balance: 0
        )
        try await uploadUserData(recoveredUser)
        return recoveredUser
    }

    func uploadUserData(_ user: User) async throws {
        let data = try Firestore.Encoder().encode(user)
        try await db.collection("users").document(user.id).setData(data)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = currentAuthUser else {
            throw AuthServiceError.notSignedIn
        }
        let uid = user.uid
        try await user.delete()
        try? await db.collection("users").document(uid).delete()
    }

    func recordPayment(amount: Double, userId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "paymentsTotal": FieldValue.increment(amount)
        ])
    }

    private func resolvedFullname(preferredName: String, authUser: FirebaseAuth.User?, email: String) -> String {
        let trimmedPreferred = preferredName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmedPreferred.lowercased()
        let isPlaceholder = trimmedPreferred.isEmpty || lowered == "user" || lowered == "account holder"
        if !isPlaceholder {
            return trimmedPreferred
        }

        let displayName = authUser?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !displayName.isEmpty {
            return displayName
        }

        let raw = email.split(separator: "@").first.map(String.init) ?? ""
        let cleaned = raw
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? "Account Holder" : cleaned.capitalized
    }

    private func numberValue(_ raw: Any?) -> Double? {
        if let number = raw as? NSNumber {
            return number.doubleValue
        }
        if let value = raw as? Double {
            return value
        }
        if let value = raw as? Int {
            return Double(value)
        }
        return nil
    }
}
