//
//  ProfileView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var cartVM: CartViewModel
    @State private var showDeletePrompt = false
    @State private var isDeletingAccount = false
    @State private var deleteErrorMessage = ""
    @State private var showDeleteError = false
    @State private var didRequestUserReload = false
    @State private var showWhosShopping = false
    @State private var showAddProfile = false
    @State private var showSwitchAccountsHint = false
    @State private var showAppSettings = false
    @State private var appSettingsDetent: PresentationDetent = .fraction(0.5)

    var body: some View {
        if let user = authVM.currentUser {
            ZStack {
                VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Button {
                        showWhosShopping = true
                    } label: {
                        HStack(spacing: 14) {
                            Text(user.initials)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 52, height: 52)
                                .background(StampyTheme.ink)
                                .clipShape(Circle())

                            HStack(spacing: 6) {
                                Text("Hello, \(greetingName(for: user))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)

                                Image(systemName: "chevron.down")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 8)

                    Button {
                        showAppSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(Color(white: 0.35))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

                List {
                    Section {
                        NavigationLink {
                            MyStampsView()
                                .environmentObject(cartVM)
                        } label: {
                            ProfileRow(icon: "square.grid.2x2", title: "My Stamps", showsChevron: false)
                        }

                        NavigationLink {
                            FavoritesView()
                                .environmentObject(cartVM)
                        } label: {
                            ProfileRow(icon: "heart", title: "Favorites", showsChevron: false)
                        }

                        NavigationLink {
                            CartView()
                                .environmentObject(cartVM)
                                .environmentObject(authVM)
                        } label: {
                            ProfileRow(icon: "cart", title: "My Cart", showsChevron: false)
                        }

                        NavigationLink {
                            PaymentsView(totalPayments: authVM.currentUser?.paymentsTotal ?? 0)
                                .environmentObject(cartVM)
                        } label: {
                            ProfileRow(icon: "creditcard", title: "Payments", showsChevron: false)
                        }

                        NavigationLink {
                            BalanceView(balance: authVM.currentUser?.balance ?? 0)
                        } label: {
                            ProfileRow(icon: "dollarsign.circle", title: "Balance", showsChevron: false)
                        }
                    }

                    Section("Account") {
                        Button {
                            showDeletePrompt = true
                        } label: {
                            ProfileRow(icon: "trash", title: "Delete Account", tint: .red)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.white)
            }
                if showDeletePrompt {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        Text("Are you sure you want to delete your account?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)

                        HStack(spacing: 14) {
                            Button {
                                showDeletePrompt = false
                            } label: {
                                Text("No")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button {
                                showDeletePrompt = false
                                isDeletingAccount = true
                                Task {
                                    do {
                                        try await authVM.deleteAccount()
                                    } catch {
                                        deleteErrorMessage = error.localizedDescription
                                        showDeleteError = true
                                    }
                                    isDeletingAccount = false
                                }
                            } label: {
                                Group {
                                    if isDeletingAccount {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Yes")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(StampyTheme.ink)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isDeletingAccount)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 30)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .sheet(isPresented: $showWhosShopping) {
                WhosShoppingSheet(
                    user: user,
                    onAddProfile: {
                        showWhosShopping = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            showAddProfile = true
                        }
                    },
                    onSwitchAccounts: {
                        showWhosShopping = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            showSwitchAccountsHint = true
                        }
                    },
                    onSignOut: {
                        authVM.signOut()
                    }
                )
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showAddProfile) {
                AddProfileView()
            }
            .alert("Switch accounts", isPresented: $showSwitchAccountsHint) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Sign out, then sign in with a different email to use another account.")
            }
            .alert("Delete account failed", isPresented: $showDeleteError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage)
            }
            .sheet(isPresented: $showAppSettings) {
                AppSettingsSheet(selectedDetent: $appSettingsDetent)
                    .presentationDetents(
                        [.fraction(0.5), .fraction(0.85), .large],
                        selection: $appSettingsDetent
                    )
                    .presentationDragIndicator(.hidden)
            }
            .onChange(of: showAppSettings) { _, isOpen in
                if !isOpen {
                    appSettingsDetent = .fraction(0.5)
                }
            }
        } else {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading profile...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .task {
                guard !didRequestUserReload else { return }
                didRequestUserReload = true
                await authVM.loadUserIfLoggedIn()
            }
        }
    }

    private func greetingName(for user: User) -> String {
        let trimmed = user.fullname.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: " ")
        if let first = parts.first {
            return String(first)
        }
        return trimmed.isEmpty ? "there" : trimmed
    }

}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(CartViewModel())
    }
}
