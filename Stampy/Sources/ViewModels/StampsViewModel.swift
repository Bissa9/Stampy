//
//  StampsViewModel.swift
//  Stampy
//

import Foundation
import UIKit

@MainActor
class StampViewModel: ObservableObject {
    @Published var stamps: [Stamp] = []
    @Published var isLoading = false
    @Published var loadError: String?

    private let stampService = StampService()

    func fetchStamps() async {
        if stamps.isEmpty {
            isLoading = true
        }
        loadError = nil
        do {
            stamps = try await stampService.fetchStamps()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    func uploadStamp(image: UIImage, name: String, description: String?, menuCategory: String?) async throws {
        try await stampService.uploadStamp(
            image: image,
            name: name,
            description: description,
            menuCategory: menuCategory
        )
    }
}
