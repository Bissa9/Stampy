//
//  PermissionAccessPromptSheet.swift
//  Stampy
//

import SwiftUI
import UIKit

struct PermissionAccessPromptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let message: String
    let onNotNow: () -> Void
    let onGoToSettings: (() -> Void)?

    init(
        message: String,
        onNotNow: @escaping () -> Void,
        onGoToSettings: (() -> Void)? = nil
    ) {
        self.message = message
        self.onNotNow = onNotNow
        self.onGoToSettings = onGoToSettings
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            VStack(alignment: .center, spacing: 18) {
                Button {
                    onNotNow()
                    dismiss()
                } label: {
                    Text("Not now")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.primary)
                }
                .buttonStyle(.plain)

                Button {
                    onGoToSettings?()
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                    dismiss()
                } label: {
                    Text("Go to settings")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(StampyTheme.ink)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}
