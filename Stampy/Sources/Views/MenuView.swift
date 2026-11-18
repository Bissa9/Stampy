//
//  MenuView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 11/01/2026.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @State private var searchText = ""

    private var categories: [String] { MenuCategories.all }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var filteredCategories: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return categories }
        return categories.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SearchBar(searchText: $searchText)

                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(filteredCategories, id: \.self) { category in
                            NavigationLink {
                                MenuCategoryItemsView(category: category)
                                    .environmentObject(cartVM)
                            } label: {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.72))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(StampyTheme.ink.opacity(0.35), lineWidth: 1)
                                    }
                                    .frame(height: 96)
                                    .overlay {
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(StampyTheme.ink)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 6)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Menu")
            .background(StampyTheme.paper)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(CartViewModel())
}
