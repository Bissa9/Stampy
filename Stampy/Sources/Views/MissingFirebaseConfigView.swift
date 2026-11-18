//
//  MissingFirebaseConfigView.swift
//  Stampy
//

import SwiftUI

struct MissingFirebaseConfigView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stampy")
                .font(.largeTitle.bold())
                .foregroundStyle(StampyTheme.ink)
            Text("Add the local Firebase file before the catalog can open.")
                .font(.title3)
            Text("Copy GoogleService-Info.plist into the Stampy folder, next to Assets.xcassets. Download it from the Firebase console for bundle id myPlayground.swift.Stampy. The plist is gitignored, so it stays off GitHub.")
                .foregroundStyle(.secondary)
            Text("Card checkout also needs Config/Secrets.xcconfig. Copy Config/Secrets.example.xcconfig and set STRIPE_PUBLISHABLE_KEY, then rebuild.")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(StampyTheme.paper)
    }
}
