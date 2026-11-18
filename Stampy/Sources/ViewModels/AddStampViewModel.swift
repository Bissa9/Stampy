//
//  AddStampViewModel.swift
//  Stampy
//

import Foundation
import UIKit

@MainActor
final class AddStampViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var name = ""
    @Published var details = ""
    @Published var menuCategory: String = MenuCategories.all[0]
    @Published var isUploading = false
    @Published var errorMessage: String?

    private let stampService = StampService()

    var canUpload: Bool {
        image != nil
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isUploading
    }

    func setImageData(_ data: Data?) {
        guard let data, let uiImage = UIImage(data: data) else {
            image = nil
            return
        }
        image = uiImage
    }

    func upload() async -> Bool {
        guard let image else { return false }
        isUploading = true
        errorMessage = nil
        defer { isUploading = false }
        do {
            try await stampService.uploadStamp(
                image: image,
                name: name,
                description: details,
                menuCategory: menuCategory
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
