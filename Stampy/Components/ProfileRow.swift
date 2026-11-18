//
//  ProfileRow.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 04/02/2026.
//

import SwiftUI

struct ProfileRow: View {
    let icon: String
    let title: String
    var tint: Color = .primary
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(tint)
                .frame(width: 24)

            Text(title)
                .foregroundColor(tint)

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
