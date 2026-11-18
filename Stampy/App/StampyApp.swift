//
//  StampyApp.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import SwiftUI
import FirebaseCore
import Stripe

@main
struct StampyApp: App {
    @StateObject private var authVM: AuthViewModel
    @StateObject private var cartVM = CartViewModel()
    private let firebaseReady: Bool

    init() {
        let ready = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        firebaseReady = ready
        if ready {
            FirebaseApp.configure()
            if StripeConfig.isPublishableKeyConfigured {
                StripeAPI.defaultPublishableKey = StripeConfig.publishableKey
            }
        }
        _authVM = StateObject(wrappedValue: AuthViewModel(startsSession: ready))
    }

    var body: some Scene {
        WindowGroup {
            if firebaseReady {
                authenticatedRoot
            } else {
                MissingFirebaseConfigView()
            }
        }
    }

    private var authenticatedRoot: some View {
        ZStack {
            if authVM.userSession != nil {
                TabView {
                    HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }

                    MenuView()
                    .tabItem {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
                .tint(StampyTheme.ink)
                .environmentObject(authVM)
                .environmentObject(cartVM)
            } else {
                AuthSwitcher()
                    .environmentObject(authVM)
            }

            if authVM.isAuthTransitioning {
                Color.black.opacity(0.12)
                    .ignoresSafeArea()
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Please wait...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
