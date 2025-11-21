//
//  SearchViewModel.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

/// ViewModel responsible for searching photos from Unsplash.
/// Supports debounced search, pagination, and error handling.
@MainActor
final class SearchViewModel: ObservableObject {

    /// User's current search query
    @Published var searchQuery = ""

    /// Photos matching the current search query
    @Published var filteredPhotos: [Photo] = []

    /// Loading state for UI feedback
    @Published var isLoading = false

    /// Indicates whether there are more results to load
    @Published var hasMoreResults = true

    /// Unsplash API client
    private let client: UnsplashAPIClientProtocol

    /// Current page for pagination
    private var currentPage = 1

    /// Number of results per page
    private let perPage = 20

    /// Total number of results returned by the API
    private var totalResults = 0

    /// Task used for debouncing search input
    private var searchTask: Task<Void, Never>? = nil

    /// Designated initializer
    /// - Parameter client: API client
    init(client: UnsplashAPIClientProtocol) {
        self.client = client
    }

    /// Convenience initializer that creates the default client on the main actor.
    convenience init() {
        self.init(client: UnsplashAPIClient())
    }

    // MARK: - Search with Debounce

    /// Performs a debounced search to avoid excessive API calls.
    /// - Parameter query: The search query string
    func debouncedSearch(query: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            await self?.searchPhotos(reset: true)
        }
    }

    // MARK: - Photo Search

    /// Fetches search results from the API.
    /// - Parameter reset: Whether to reset current results and pagination
    func searchPhotos(reset: Bool = false) async {
        // Ignore empty query or if already loading
        guard !searchQuery.isEmpty, !isLoading else { return }

        if reset {
            currentPage = 1
            filteredPhotos = []
            totalResults = 0
            hasMoreResults = true
        }

        guard hasMoreResults else { return }

        isLoading = true
        defer { isLoading = false }

        let result = await client.searchPhotos(query: searchQuery, page: currentPage, perPage: perPage)
        switch result {
        case .success(let response):
            // Off-main-thread decoding already done in UnsplashAPIClient
            await MainActor.run {
                filteredPhotos.append(contentsOf: response.photos.prefix(20)) // limit initial batch
                totalResults = response.total
                currentPage += 1
                hasMoreResults = filteredPhotos.count < totalResults
            }
        case .failure(let error):
            // Show API errors using ErrorManager
            Task { @MainActor in
                ErrorManager.shared.show(error: error)
            }
        }
    }
}
