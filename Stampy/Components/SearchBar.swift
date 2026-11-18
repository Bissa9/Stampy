//
//  SearchBar.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 03/01/2026.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(StampyTheme.ink)

            TextField("Search", text: $searchText)
                .textInputAutocapitalization(.none)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


#Preview {
    SearchBar(searchText: .constant(""))
            .padding()
}
