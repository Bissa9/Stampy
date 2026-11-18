//
//  ImageService.swift
//  Stampy
//

import Foundation
import UIKit
import FirebaseStorage

enum ImageServiceError: LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Could not prepare the photo for upload."
        }
    }
}

struct ImageService {
    private let storage = Storage.storage()

    func uploadJPEG(_ image: UIImage, path: String, compressionQuality: CGFloat = 0.5) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageServiceError.encodingFailed
        }
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL()
    }
}
