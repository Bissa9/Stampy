//
//  CategoryChip.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 11/01/2026.
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .background(
            Capsule()
                .fill(isSelected ? StampyTheme.ink : Color(.systemGray6))
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? StampyTheme.ink.opacity(0.7) : Color(.systemGray4),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: isSelected ? StampyTheme.ink.opacity(0.25) : Color.black.opacity(0.06),
            radius: isSelected ? 8 : 4,
            y: 2
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }
}


#Preview {
    CategoryChip(title: "under50$", isSelected: false)
}
