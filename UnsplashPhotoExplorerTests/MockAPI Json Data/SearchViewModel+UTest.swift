//
//  SearchViewModel+UTest.swift
//  UnsplashPhotoExplorerTests
//
//  Created by Audrey Chanakira on 11/21/25.
//

import XCTest
@testable import UnsplashPhotoExplorer

final class SearchViewModel_UTest: XCTestCase {

    // MARK: - Mock API Client

    final class MockUnsplashAPIClient: UnsplashAPIClientProtocol {
        enum Mode {
            case search(Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError>)
            case randomPhotos(Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError>)
            case failure(UnsplashError)
        }

        var mode: Mode = .search(.success((photos: [], total: 0, rate: nil)))

        // Not used by SearchViewModel but required by protocol
        func fetchRandomPhotos() async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
            switch mode {
            case .randomPhotos(let result):
                return result
            case .failure(let error):
                return .failure(error)
            case .search:
                return .success((photos: [], rate: nil))
            }
        }

        func fetchRandomPhotos(count: Int) async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
            await fetchRandomPhotos()
        }

        func searchPhotos(query: String, page: Int, perPage: Int) async -> Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError> {
            switch mode {
            case .search(let result):
                return result
            case .failure(let error):
                return .failure(error)
            case .randomPhotos:
                return .success((photos: [], total: 0, rate: nil))
            }
        }
    }

    // MARK: - Helpers

    private func makePhotos(count: Int, startingAt start: Int = 0) -> [Photo] {
        (0..<count).map { i in
            Photo(
                id: "p\(start + i)",
                urls: PhotoURLs(
                    regular: URL(string: "https://example.com/r\(start + i).jpg"),
                    small: URL(string: "https://example.com/s\(start + i).jpg")
                ),
                user: User(
                    id: "u\(start + i)",
                    name: "User \(start + i)",
                    profileImage: ProfileImageURLs(
                        small: URL(string: "https://example.com/u\(start + i)-s.jpg"),
                        medium: URL(string: "https://example.com/u\(start + i)-m.jpg"),
                        large: URL(string: "https://example.com/u\(start + i)-l.jpg")
                    ),
                    links: UserLinks(html: "https://example.com/u\(start + i)", photos: nil, portfolio: nil)
                ),
                exif: nil
            )
        }
    }

    // MARK: - Tests

    func testSearchSuccess_PopulatesResultsAndPagination() async {
        // Arrange
        let mock = MockUnsplashAPIClient()
        let page1 = makePhotos(count: 5, startingAt: 0)
        mock.mode = .search(.success((photos: page1, total: 9, rate: nil)))

        let vm: SearchViewModel = await MainActor.run { SearchViewModel(client: mock) }
        await MainActor.run { vm.searchQuery = "nature" }

        // Act: first page
        await vm.searchPhotos(reset: true)

        // Assert
        let firstCount = await MainActor.run { vm.filteredPhotos.count }
        let hasMore = await MainActor.run { vm.hasMoreResults }
        XCTAssertEqual(firstCount, 5)
        XCTAssertTrue(hasMore, "Should have more when total > loaded")

        // Arrange: second page response
        let page2 = makePhotos(count: 4, startingAt: 5)
        mock.mode = .search(.success((photos: page2, total: 9, rate: nil)))

        // Act: second page
        await vm.searchPhotos()

        // Assert appended and no more results now
        let finalState = await MainActor.run { (vm.filteredPhotos.count, vm.hasMoreResults) }
        XCTAssertEqual(finalState.0, 9)
        XCTAssertFalse(finalState.1, "Should have no more when loaded == total")
    }

    func testSearchFailure_ShowsNoCrashAndKeepsState() async {
        // Arrange
        let mock = MockUnsplashAPIClient()
        mock.mode = .failure(.networkError(URLError(.notConnectedToInternet)))

        let vm: SearchViewModel = await MainActor.run { SearchViewModel(client: mock) }
        await MainActor.run {
            vm.searchQuery = "ocean"
            vm.hasMoreResults = true
        }

        // Act
        await vm.searchPhotos(reset: true)

        // Assert
        let state = await MainActor.run { (vm.filteredPhotos.isEmpty, vm.isLoading, vm.hasMoreResults) }
        XCTAssertTrue(state.0, "Results should remain empty on failure")
        XCTAssertFalse(state.1, "isLoading should be false after failure")
        XCTAssertTrue(state.2, "hasMoreResults should not be turned off by a failure")
    }

    func testNoSearchWhenQueryEmptyOrAlreadyLoading() async {
        // Arrange
        let mock = MockUnsplashAPIClient()
        mock.mode = .search(.success((photos: makePhotos(count: 3), total: 3, rate: nil)))

        let vm: SearchViewModel = await MainActor.run { SearchViewModel(client: mock) }

        // Act: empty query should not trigger
        await vm.searchPhotos(reset: true)
        var count = await MainActor.run { vm.filteredPhotos.count }
        XCTAssertEqual(count, 0, "Should not search when query is empty")

        // Set query and simulate isLoading true to verify guard
        await MainActor.run {
            vm.searchQuery = "mountains"
            vm.isLoading = true
        }
        await vm.searchPhotos(reset: true)
        count = await MainActor.run { vm.filteredPhotos.count }
        XCTAssertEqual(count, 0, "Should not search when already loading")
    }

    func testNoRefetchWhenNoMoreResults() async {
        // Arrange
        let mock = MockUnsplashAPIClient()
        let page = makePhotos(count: 2)
        mock.mode = .search(.success((photos: page, total: 2, rate: nil)))

        let vm: SearchViewModel = await MainActor.run { SearchViewModel(client: mock) }
        await MainActor.run { vm.searchQuery = "city" }

        // Load first (and only) page
        await vm.searchPhotos(reset: true)

        // Assert no more results
        let hasMoreAfterFirst = await MainActor.run { vm.hasMoreResults }
        XCTAssertFalse(hasMoreAfterFirst)

        // Act: attempt another fetch; since hasMoreResults == false, it should bail out
        // Change mock to a failure to ensure it wouldn't be called if guard works
        mock.mode = .failure(.unknown)
        await vm.searchPhotos()

        // Assert still 2 results
        let count = await MainActor.run { vm.filteredPhotos.count }
        XCTAssertEqual(count, 2, "When no more results, subsequent searchPhotos should not change results")
    }

    func testDebouncedSearch_CallsSearchAfterDelay() async {
        // Arrange
        let mock = MockUnsplashAPIClient()
        let results = makePhotos(count: 3)
        mock.mode = .search(.success((photos: results, total: 3, rate: nil)))

        let vm: SearchViewModel = await MainActor.run { SearchViewModel(client: mock) }
        await MainActor.run { vm.searchQuery = "flowers" }

        // Act: trigger debounced search
        await MainActor.run { vm.debouncedSearch(query: "flowers") }

        // Wait a bit longer than debounce (0.3s) to allow it to fire
        try? await Task.sleep(nanoseconds: 400_000_000)

        // Assert results populated
        let count = await MainActor.run { vm.filteredPhotos.count }
        XCTAssertEqual(count, 3, "Debounced search should eventually populate results")
    }
}
