//
//  PurplePressButtonStyle.swift
//  Stampy
//

import SwiftUI

/// Filled purple button: background darkens while the finger is down (same idea as Checkout).
struct PurplePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? StampyTheme.pressedInk : StampyTheme.ink)
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
