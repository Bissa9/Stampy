//
//  CartButton.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 02/01/2026.
//

import SwiftUI

struct CartButton: View {
    @ObservedObject var cart: CartViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "cart")
                .font(.system(size: 24))
                .foregroundColor(StampyTheme.ink)

            if cart.itemCount > 0 {
                Text("\(cart.itemCount)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }
}

#Preview {
    CartButton(cart: CartViewModel())
}
