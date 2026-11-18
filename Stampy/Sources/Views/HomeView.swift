//
//  HomeView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var vm = StampViewModel()
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showUpload = false
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil

    private let preferredCategoryOrder = [
        "All",
        "Rubbers",
        "Inks",
        "Paris stamps",
        "Envelopes",
        "Ancient stamps",
        "Papers",
        "Rare",
        "New Arrivals",
        "Under $25",
        "Under $50"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Stampy")
                                    .font(.title.bold())
                                    .foregroundStyle(StampyTheme.ink)
                                Text("Postage, inks, and paper")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            NavigationLink {
                                CartView()
                            } label: {
                                CartButton(cart: cartVM)
                            }
                            Button {
                                showUpload = true
                            } label: {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(StampyTheme.ink)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Add a stamp")
                        }
                        SearchBar(searchText: $searchText)
                        ImageSlider()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    Section {
                        Text(selectedCategory ?? "Hot deals")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        catalogBody
                    } header: {
                        ScrollableList(
                            categories: categories,
                            selectedCategory: $selectedCategory
                        )
                        .padding(.vertical, 8)
                        .background(StampyTheme.paper)
                    }
                }
            }
            .background(StampyTheme.paper)
            .navigationDestination(isPresented: $showUpload) {
                AddStampView(vm: vm)
            }
            .task {
                await vm.fetchStamps()
            }
        }
        .environmentObject(cartVM)
    }

    @ViewBuilder
    private var catalogBody: some View {
        if vm.isLoading && vm.stamps.isEmpty {
            VStack(spacing: 10) {
                ProgressView()
                Text("Loading the catalog")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
        } else if let loadError = vm.loadError, vm.stamps.isEmpty {
            VStack(spacing: 12) {
                Text("The catalog didn't load")
                    .font(.headline)
                Text(loadError)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Try again") {
                    Task { await vm.fetchStamps() }
                }
                .buttonStyle(.borderedProminent)
                .tint(StampyTheme.ink)
            }
            .padding(24)
        } else if filteredStamps.isEmpty {
            Text(emptyResultsMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal)
        } else {
            StampsList(stamps: filteredStamps)
        }
    }

    // 🔹 Category filter, then live search (name, description, category, country, tags, year).
    var filteredStamps: [Stamp] {
        let categoryFiltered: [Stamp]
        if let category = selectedCategory, category != "All" {
            let lowered = category.lowercased()
            categoryFiltered = vm.stamps.filter { stamp in
                let stampCategory = stamp.category?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                switch lowered {
                case "rare":
                    return stamp.tags?.contains(where: { $0.lowercased() == "rare" }) == true
                        || stampCategory == "rare"
                case "new arrivals":
                    return true
                case "under $25":
                    return (stamp.price ?? .greatestFiniteMagnitude) <= 25
                case "under $50":
                    return (stamp.price ?? .greatestFiniteMagnitude) <= 50
                default:
                    return MenuCategories.matches(stamp.category, category: category)
                        || MenuCategories.matches(stamp.menuCategory, category: category)
                }
            }
        } else {
            categoryFiltered = vm.stamps
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return categoryFiltered }

        return categoryFiltered.filter { stampMatchesSearch($0, query: query) }
    }

    private func stampMatchesSearch(_ stamp: Stamp, query: String) -> Bool {
        let q = query.lowercased()
        if stamp.name.lowercased().contains(q) { return true }
        if let description = stamp.description, description.lowercased().contains(q) { return true }
        if let category = stamp.category, category.lowercased().contains(q) { return true }
        if let menuCategory = stamp.menuCategory, menuCategory.lowercased().contains(q) { return true }
        if let country = stamp.country, country.lowercased().contains(q) { return true }
        if let tags = stamp.tags, tags.contains(where: { $0.lowercased().contains(q) }) { return true }
        if let year = stamp.year, String(year).contains(query) { return true }
        if let price = stamp.price {
            let priceStr = String(format: "%.2f", price)
            if priceStr.contains(query) || String(Int(price)) == query { return true }
        }
        return false
    }

    private var emptyResultsMessage: String {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            return "No stamps match \"\(q)\""
        }
        return "No stamps in this category"
    }

    private var categories: [String] {
        let existing = Set(
            vm.stamps.compactMap {
                $0.category?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
            .map(MenuCategories.displayName)
        )

        var combined: [String] = []
        for category in preferredCategoryOrder where category == "All" || existing.contains(category) {
            combined.append(category)
        }

        let leftovers = existing
            .filter { !combined.contains($0) }
            .sorted()
        combined.append(contentsOf: leftovers)
        return combined.isEmpty ? ["All"] : combined
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(CartViewModel())
}
