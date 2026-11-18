//
//  AddProfileView.swift
//  Stampy
//

import PhotosUI
import SwiftUI
import UIKit

struct AddProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var profileName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        profileAvatar
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Choose a Profile Picture")
                                .font(.body)
                                .foregroundStyle(StampyTheme.ink)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                profileImageData = data
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Text("Profile name")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("(required)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        TextField("", text: $profileName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(
                        "By creating a profile, you agree to Stampy's Privacy Notice and Conditions of Use."
                    )
                    .font(.footnote)
                    .foregroundStyle(Color(white: 0.35))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.vertical, 8)

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.body)
                                .foregroundStyle(StampyTheme.ink)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            // Hook: persist profile when backend exists
                            dismiss()
                        } label: {
                            Text("Create")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? StampyTheme.ink.opacity(0.4) : StampyTheme.ink)
                        }
                        .buttonStyle(.plain)
                        .disabled(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var profileAvatar: some View {
        Group {
            if let data = profileImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color(.systemGray3))
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
    }
}
