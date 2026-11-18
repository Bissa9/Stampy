//
//  WhosShoppingSheet.swift
//  Stampy
//

import SwiftUI

struct WhosShoppingSheet: View {
    @Environment(\.dismiss) private var dismiss

    let user: User
    let onAddProfile: () -> Void
    let onSwitchAccounts: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileSheetChrome(title: "Who's Shopping?", onDismiss: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.fullname)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.primary)

                        Text("Account holder")
                            .font(.subheadline)
                            .foregroundStyle(Color(white: 0.35))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    HStack(alignment: .center) {
                        Button {
                            onAddProfile()
                        } label: {
                            Text("Add Profile")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(StampyTheme.ink)
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 8)

                        Text("Remove profile")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .opacity(0.35)
                            .allowsHitTesting(false)
                    }

                    Text("Signed in as \(user.email)")
                        .font(.subheadline)
                        .foregroundStyle(Color(white: 0.35))

                    Button {
                        onSwitchAccounts()
                    } label: {
                        Text("Switch Accounts")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(StampyTheme.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Button {
                        dismiss()
                        onSignOut()
                    } label: {
                        Text("Sign Out")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(StampyTheme.ink)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}
