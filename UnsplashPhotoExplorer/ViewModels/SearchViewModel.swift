//
//  SearchViewModel.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var filteredPhotos: [Photo] = []
    @Published var isLoading = false
    @Published var hasMoreResults = true

    private let client: UnsplashAPIClientProtocol
    private var currentPage = 1
    private let perPage = 20
    private var totalResults = 0

    private var searchTask: Task<Void, Never>? = nil

    init(client: UnsplashAPIClientProtocol = UnsplashAPIClient()) {
        self.client = client
    }

    func debouncedSearch(query: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s debounce
            await self?.searchPhotos(reset: true)
        }
    }

    func searchPhotos(reset: Bool = false) async {
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
            filteredPhotos.append(contentsOf: response.photos)
            totalResults = response.total
            currentPage += 1
            hasMoreResults = filteredPhotos.count < totalResults
        case .failure(let error):
            Task { @MainActor in
                ErrorManager.shared.show(error: error)
            }
        }
    }
}
