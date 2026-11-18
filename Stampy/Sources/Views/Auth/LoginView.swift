//
//  LoginView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import SwiftUI
import UIKit

struct LoginView: View, AuthenticationFormProtocol {
    var showsAccountLink: Bool = true
    @State private var email = ""
    @State private var password = ""
    @State private var authMessage: String?
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var formIsValid: Bool {
        return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count >= 8
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showsAccountLink {
                Spacer()
            }
            
            InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
            
            InputView(text: $password, title: "Password", placeholder: "At least 8 characters", isSecureField: true)

            if let authMessage {
                Text(authMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                dismissKeyboard()
                authMessage = nil
                Task {
                    do {
                        try await authVM.signIn(email: email, password: password)
                    } catch {
                        authMessage = error.localizedDescription
                    }
                }
            } label: {
                Text("Login")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(formIsValid ? StampyTheme.ink : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(!formIsValid)

            if showsAccountLink {
                Spacer()
                NavigationLink {
                    RegistrationView()
                        .environmentObject(authVM)
                } label: {
                    HStack {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(StampyTheme.ink)
                    .font(.system(size: 14))
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(showsAccountLink ? "Login" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(showsAccountLink ? .automatic : .hidden, for: .navigationBar)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView()
}
