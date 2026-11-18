//
//  AppSettingsSheet.swift
//  Stampy
//

import SwiftUI

private enum AppSettingsRoute {
    case root
    case permissions
}

struct AppSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDetent: PresentationDetent

    @State private var route: AppSettingsRoute = .root

    var body: some View {
        VStack(spacing: 0) {
            ProfileSheetChrome(
                title: route == .permissions ? "Permissions" : "App Settings",
                onDismiss: { dismiss() },
                onTitleTap: route == .permissions ? { route = .root } : nil
            )

            Group {
                switch route {
                case .root:
                    appSettingsRoot
                case .permissions:
                    PermissionsDashboardView(
                        onExpandedSectionsChange: { anyExpanded in
                            selectedDetent = anyExpanded ? .large : .fraction(0.85)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .onChange(of: route) { _, newRoute in
            if newRoute == .permissions {
                selectedDetent = .fraction(0.85)
            } else {
                selectedDetent = .fraction(0.5)
            }
        }
        .onAppear {
            selectedDetent = route == .permissions ? .fraction(0.85) : .fraction(0.5)
        }
    }

    private var appSettingsRoot: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Button {
                    route = .permissions
                } label: {
                    HStack {
                        Text("Permissions")
                            .font(.body)
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    // Hook: manage storage
                } label: {
                    Text("Manage App Storage")
                        .font(.body)
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Button {
                    // Hook: legal & about
                } label: {
                    Text("Legal & About")
                        .font(.body)
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
}
