//
//  AuthViewModel.swift
//  Stampy
//

import Foundation
import FirebaseAuth

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isAuthTransitioning = false

    private let authService = AuthService()

    init(startsSession: Bool = true) {
        guard startsSession else { return }
        self.userSession = authService.currentAuthUser
        Task {
            try? await fetchUser()
        }
    }

    func signIn(email: String, password: String) async throws {
        let user = try await authService.signIn(email: email, password: password)
        self.userSession = user
        try await fetchUser()
    }

    func createUser(email: String, password: String, fullname: String) async throws {
        let user = try await authService.createUser(email: email, password: password, fullname: fullname)
        self.userSession = authService.currentAuthUser
        self.currentUser = user
    }

    func fetchUser() async throws {
        self.currentUser = try await authService.fetchUser()
    }

    func loadUserIfLoggedIn() async {
        guard authService.currentAuthUser != nil else { return }
        self.userSession = authService.currentAuthUser
        try? await fetchUser()
    }

    func signOut() {
        isAuthTransitioning = true
        try? authService.signOut()
        self.userSession = nil
        self.currentUser = nil
    }

    func deleteAccount() async throws {
        guard authService.currentAuthUser != nil else { return }
        isAuthTransitioning = true
        do {
            try await authService.deleteAccount()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            isAuthTransitioning = false
            throw error
        }
    }

    func recordPayment(amount: Double) async {
        guard amount > 0, let uid = currentUser?.id else { return }
        do {
            try await authService.recordPayment(amount: amount, userId: uid)
            if var user = currentUser {
                user.paymentsTotal += amount
                currentUser = user
            }
        } catch {
            print("Failed to record payment:", error.localizedDescription)
        }
    }
}
