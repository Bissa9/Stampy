//
//  ProfileSheetChrome.swift
//  Stampy
//

import SwiftUI

/// Shared drag handle + title + close for profile bottom sheets.
struct ProfileSheetChrome: View {
    let title: String
    let onDismiss: () -> Void
    /// When set (e.g. Permissions sub-screen), tapping the title performs this action (e.g. return to App Settings).
    var onTitleTap: (() -> Void)?

    init(title: String, onDismiss: @escaping () -> Void, onTitleTap: (() -> Void)? = nil) {
        self.title = title
        self.onDismiss = onDismiss
        self.onTitleTap = onTitleTap
    }

    private let handleWidth: CGFloat = 40
    private let handleHeight: CGFloat = 5

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onDismiss()
            } label: {
                RoundedRectangle(cornerRadius: handleHeight / 2)
                    .fill(Color(.systemGray3))
                    .frame(width: handleWidth, height: handleHeight)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .accessibilityLabel("Dismiss")

            HStack(alignment: .center) {
                Group {
                    if let onTitleTap {
                        Button(action: onTitleTap) {
                            Text(title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primary)
                    }
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}
