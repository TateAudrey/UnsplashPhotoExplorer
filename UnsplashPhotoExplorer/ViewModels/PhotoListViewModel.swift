//
//  PhotoListViewModel.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PhotoListViewModel: ObservableObject {
    
    @Published private(set) var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: UnsplashAPIClientProtocol
    private let cacheKey = "cachedPhotos"

    init(api: UnsplashAPIClientProtocol) {
        self.api = api
        loadCachedPhotos()
    }

    private func loadCachedPhotos() {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey),
           let savedPhotos = try? JSONDecoder().decode([Photo].self, from: savedData) {
            self.photos = savedPhotos
        }
    }

    private func savePhotosToCache(_ photos: [Photo]) {
        if let encoded = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    func load() async {
        // If cached photos exist, skip API call
        if !photos.isEmpty {
            return
        }

        isLoading = true
        errorMessage = nil

        let result = await api.fetchRandomPhotos()

        isLoading = false

        switch result {
        case .success(let data):
            self.photos = data.photos
            savePhotosToCache(data.photos) // persist photos

            if let limit = data.rate?.limit,
               let remaining = data.rate?.remaining,
               remaining < Int(Double(limit) * 0.1) {
                errorMessage = "Warning: API rate limit low (\(remaining)/\(limit))."
            }

        case .failure(let error):
            Task { @MainActor in
                ErrorManager.shared.show(error: error)
            }
        }
    }

    func refresh() async {
        // Clear cached photos before refreshing
        UserDefaults.standard.removeObject(forKey: cacheKey)
        photos = []
        await load()
    }
}

