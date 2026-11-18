//
//  MenuCategoryItemsView.swift
//  Stampy
//

import SwiftUI

struct MenuCategoryItemsView: View {
    let category: String
    @StateObject private var vm = StampViewModel()
    @EnvironmentObject var cartVM: CartViewModel

    private var stampsInCategory: [Stamp] {
        vm.stamps.filter { stamp in
            guard let raw = stamp.menuCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
                return false
            }
            return MenuCategories.matches(raw, category: category)
        }
    }

    var body: some View {
        Group {
            if vm.isLoading && vm.stamps.isEmpty {
                ProgressView("Loading the catalog")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 40)
            } else if stampsInCategory.isEmpty {
                Text("No items in this category yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 40)
            } else {
                ScrollView {
                    StampsList(stamps: stampsInCategory)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.fetchStamps()
        }
    }
}

#Preview {
    NavigationStack {
        MenuCategoryItemsView(category: "Rubbers")
            .environmentObject(CartViewModel())
    }
}
