//
//  ScrollableList.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 10/01/2026.
//

import SwiftUI

struct ScrollableList: View {
    let categories: [String]
    @Binding var selectedCategory: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory == category
                    )
                    .onTapGesture {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


// MARK: - Preview
struct ScrollableList_Previews: PreviewProvider {
    @State static var selectedCategory: String? = nil

    static var previews: some View {
        ScrollableList(
            categories: ["All", "Deals", "Rubbers", "Favorites"],
            selectedCategory: $selectedCategory
        )
    }
}
