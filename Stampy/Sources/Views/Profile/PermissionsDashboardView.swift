//
//  PermissionsDashboardView.swift
//  Stampy
//

import SwiftUI

struct PermissionsDashboardView: View {
    /// Called when Photos or Motion dropdowns expand/collapse so the host sheet can grow/shrink.
    var onExpandedSectionsChange: (Bool) -> Void = { _ in }

    @State private var photosExpanded = false
    @State private var motionExpanded = false

    @State private var photosSwitchOn = false
    @State private var motionSwitchOn = false

    @State private var showPhotosAccessPrompt = false
    @State private var showMotionAccessPrompt = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Permissions dashboard")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)

                Text(
                    "Here you can manage how Stampy accesses your device features and personal information. Some permissions are listed here for easy updates. For more permissions, please visit your device settings."
                )
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.35))
                .fixedSize(horizontal: false, vertical: true)

                permissionPhotosSection

                permissionMotionSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .onChange(of: photosExpanded) { _, _ in
            reportExpanded()
        }
        .onChange(of: motionExpanded) { _, _ in
            reportExpanded()
        }
        .onAppear {
            reportExpanded()
        }
        .sheet(isPresented: $showPhotosAccessPrompt) {
            PermissionAccessPromptSheet(
                message: "Allow camera and photos access to add videos to your answers?",
                onNotNow: {},
                onGoToSettings: {
                    photosSwitchOn = true
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMotionAccessPrompt) {
            PermissionAccessPromptSheet(
                message: "Allow camera and motion access for branded store experiences and augmented reality?",
                onNotNow: {},
                onGoToSettings: {
                    motionSwitchOn = true
                }
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
    }

    private func reportExpanded() {
        onExpandedSectionsChange(photosExpanded || motionExpanded)
    }

    private var permissionPhotosSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    photosExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Photos")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(photosSwitchOn ? "Enabled" : "Disabled")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Image(systemName: photosExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if photosExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Customer questions")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)

                    Text(
                        "We use your camera and photos so that you can take or upload videos for answering questions."
                    )
                    .font(.footnote)
                    .foregroundStyle(Color(white: 0.35))
                    .fixedSize(horizontal: false, vertical: true)

                    Toggle("", isOn: Binding(
                        get: { photosSwitchOn },
                        set: { newValue in
                            if newValue {
                                showPhotosAccessPrompt = true
                            } else {
                                photosSwitchOn = false
                            }
                        }
                    ))
                    .labelsHidden()
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
        }
    }

    private var permissionMotionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    motionExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Motion")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(motionSwitchOn ? "Enabled" : "Disabled")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Image(systemName: motionExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if motionExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Branded Store Experience Augmented Reality")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)

                    Text(
                        "We use your camera and motion to power branded store experiences."
                    )
                    .font(.footnote)
                    .foregroundStyle(Color(white: 0.35))
                    .fixedSize(horizontal: false, vertical: true)

                    Toggle("", isOn: Binding(
                        get: { motionSwitchOn },
                        set: { newValue in
                            if newValue {
                                showMotionAccessPrompt = true
                            } else {
                                motionSwitchOn = false
                            }
                        }
                    ))
                    .labelsHidden()
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
        }
    }
}
