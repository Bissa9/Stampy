//
//  RegistrationView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import SwiftUI
import UIKit

struct RegistrationView: View, AuthenticationFormProtocol {
    var showsAccountLink: Bool = true
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var authMessage: String?
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var formIsValid: Bool {
        return !fullName.isEmpty
            && !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count >= 8
            && password == confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showsAccountLink {
                Spacer()
            }
            
            InputView(text: $fullName, title: "Full Name", placeholder: "Enter your name")
            InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
            InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
            InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm password", isSecureField: true)
            
            // Password match indicator
            if !password.isEmpty && !confirmPassword.isEmpty {
                Text(password == confirmPassword ? "Passwords match" : "Passwords do not match")
                    .foregroundColor(password == confirmPassword ? .green : .red)
                    .font(.caption)
            }
            
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
                        try await authVM.createUser(email: email, password: password, fullname: fullName)
                        dismiss()
                    } catch {
                        authMessage = error.localizedDescription
                    }
                }
            } label: {
                Text("Register")
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
                Button {
                    dismissKeyboard()
                    dismiss()
                } label: {
                    HStack {
                        Text("Already have an account?")
                        Text("Sign in")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(StampyTheme.ink)
                    .font(.system(size: 14))
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(showsAccountLink ? "Register" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(showsAccountLink ? .automatic : .hidden, for: .navigationBar)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
