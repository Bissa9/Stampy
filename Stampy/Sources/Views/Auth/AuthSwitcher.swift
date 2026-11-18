//
//  AuthSwitcher.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 27/11/2025.
//

import SwiftUI
import UIKit

struct AuthSwitcher: View {
    @State private var isLogin = true
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Stampy")
                        .font(.largeTitle.bold())
                        .foregroundStyle(StampyTheme.ink)
                    Text("A catalog for postage stamps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 28)

                HStack(spacing: 0) {
                    modeButton("Login", selected: isLogin) {
                        dismissKeyboard()
                        isLogin = true
                    }
                    modeButton("Register", selected: !isLogin) {
                        dismissKeyboard()
                        isLogin = false
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.7))
                .clipShape(Capsule())
                .padding(.horizontal, 24)

                if isLogin {
                    LoginView(showsAccountLink: false)
                } else {
                    RegistrationView(showsAccountLink: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(StampyTheme.paper)
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            authVM.isAuthTransitioning = false
        }
    }

    private func modeButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(selected ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(selected ? Color.white : Color.secondary)
                .background(selected ? StampyTheme.ink : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AuthSwitcher()
        .environmentObject(AuthViewModel(startsSession: false))
}
