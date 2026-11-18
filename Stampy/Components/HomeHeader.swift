//
//  HomeHeader.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 03/01/2026.
//

import SwiftUI

struct HomeHeader: View {
    @Binding var searchText: String
    @ObservedObject var cartVM: CartViewModel
    let onAddTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SearchBar(searchText: $searchText)
            
            NavigationLink {
                CartView()
            } label: {
                CartButton(cart: cartVM)
            }

            Button(action: onAddTap) {
                Image(systemName: "camera")
                    .font(.system(size: 22))
                    .foregroundStyle(StampyTheme.ink)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeHeader(
        searchText: .constant(""),
        cartVM: CartViewModel(),
        onAddTap: {}
    )
    .padding()
}
