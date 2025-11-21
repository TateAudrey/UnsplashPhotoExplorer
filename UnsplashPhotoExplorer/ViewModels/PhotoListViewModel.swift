//
//  PhotoListViewModel.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel responsible for fetching, caching, and exposing a list of photos from Unsplash.
/// Conforms to `ObservableObject` for SwiftUI reactivity.
@MainActor
final class PhotoListViewModel: ObservableObject {
    
    /// Published array of photos for UI binding.
    @Published private(set) var photos: [Photo] = []
    
    /// Loading state for showing spinners or progress indicators.
    @Published var isLoading = false
    
    /// Optional error message for UI display or alert.
    @Published var errorMessage: String?

    /// API client conforming to `UnsplashAPIClientProtocol` for network requests.
    private let api: UnsplashAPIClientProtocol
    
    /// Key used to cache photos in `UserDefaults`.
    private let cacheKey = "cachedPhotos"

    /// Initializes the ViewModel with an API client and loads cached photos.
    /// - Parameter api: The Unsplash API client.
    init(api: UnsplashAPIClientProtocol) {
        self.api = api
        loadCachedPhotos()
    }

    // MARK: - Caching

    /// Loads cached photos from UserDefaults if available.
    private func loadCachedPhotos() {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey),
           let savedPhotos = try? JSONDecoder().decode([Photo].self, from: savedData) {
            self.photos = savedPhotos
        }
    }

    /// Saves the given photos to UserDefaults for offline access.
    /// - Parameter photos: The photos array to cache.
    private func savePhotosToCache(_ photos: [Photo]) {
        if let encoded = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    // MARK: - Data Loading

    /// Loads photos from the API if no cached photos exist.
    /// Updates `photos`, `isLoading`, and `errorMessage` accordingly.
    func load() async {
        // Skip API call if cached photos already exist
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
            savePhotosToCache(data.photos) // Persist photos for offline use

            // Optional: Warn if API rate limit is low
            if let limit = data.rate?.limit,
               let remaining = data.rate?.remaining,
               remaining < Int(Double(limit) * 0.1) {
                errorMessage = "Warning: API rate limit low (\(remaining)/\(limit))."
            }

        case .failure(let error):
            // Show error via ErrorManager singleton
            Task { @MainActor in
                ErrorManager.shared.show(error: error)
            }
        }
    }

    /// Refreshes the photo list by clearing cached photos and fetching new ones.
    func refresh() async {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        photos = []
        await load()
    }
}
