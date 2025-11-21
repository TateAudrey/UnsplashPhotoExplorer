//
//  PhotoListViewModel+UTest.swift
//  UnsplashPhotoExplorerTests
//
//  Core Business Logic Tests
//
//  Created by Audrey Chanakira on 11/21/25.
//

import XCTest
@testable import UnsplashPhotoExplorer

final class PhotoListViewModel_UTest: XCTestCase {

    // MARK: - Mock API Client

    final class MockUnsplashAPIClient: UnsplashAPIClientProtocol {
        enum Mode {
            case randomPhotos(Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError>)
            case failure(UnsplashError)
        }

        var mode: Mode = .randomPhotos(.success((photos: [], rate: nil)))

        // Required by protocol: zero-argument overload
        func fetchRandomPhotos() async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
            await fetchRandomPhotos(count: 20)
        }

        func fetchRandomPhotos(count: Int) async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
            switch mode {
            case .randomPhotos(let result):
                return result
            case .failure(let error):
                return .failure(error)
            }
        }

        func searchPhotos(query: String, page: Int, perPage: Int) async -> Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError> {
            // Not used in these tests
            return .failure(.unknown)
        }
    }

    // MARK: - Helpers

    override func setUp() {
        super.setUp()
        // Start each test with a clean cache
        UserDefaults.standard.removeObject(forKey: "cachedPhotos")
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: "cachedPhotos")
    }

    private func loadMockPhotosFromJSON() throws -> [Photo] {
        // The JSON file is in the test bundle.
        // Ensure the test target includes MockAPI.json in its resources (Copy Bundle Resources).
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "MockAPI", withExtension: "json") else {
            XCTFail("MockAPI.json not found in test bundle. Make sure it's added to the test target resources.")
            return []
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Photo].self, from: data)
    }

    private func encodeToCache(_ photos: [Photo], key: String = "cachedPhotos") throws {
        let data = try JSONEncoder().encode(photos)
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - Tests

    func testLoadPhotosSuccess_UsesMockJSON() async throws {
        // Arrange
        let mockPhotos = try loadMockPhotosFromJSON()
        let mockAPI = MockUnsplashAPIClient()
        mockAPI.mode = .randomPhotos(.success((photos: mockPhotos, rate: RateLimitInfo(limit: 100, remaining: 80, reset: nil))))

        let vm: PhotoListViewModel = await MainActor.run { PhotoListViewModel(api: mockAPI) }

        // Act
        await vm.load()

        // Assert (snapshot values on main actor first)
        let count = await MainActor.run { vm.photos.count }
        let isLoading = await MainActor.run { vm.isLoading }
        let errorMessage = await MainActor.run { vm.errorMessage }

        XCTAssertEqual(count, mockPhotos.count, "ViewModel should populate photos from MockAPI.json")
        XCTAssertFalse(isLoading)
        XCTAssertNil(errorMessage)
    }

    func testLoadPhotosFailure_ShowsNoCrashAndNoPhotos() async {
        // Arrange
        let mockAPI = MockUnsplashAPIClient()
        mockAPI.mode = .failure(.networkError(URLError(.notConnectedToInternet)))

        let vm: PhotoListViewModel = await MainActor.run { PhotoListViewModel(api: mockAPI) }

        // Act
        await vm.load()

        // Assert
        let isEmpty = await MainActor.run { vm.photos.isEmpty }
        let isLoading = await MainActor.run { vm.isLoading }
        let errorMessage = await MainActor.run { vm.errorMessage }

        XCTAssertTrue(isEmpty, "Photos should be empty on failure")
        XCTAssertFalse(isLoading)
        // Error presentation is delegated to ErrorManager; ViewModel errorMessage is used for rate warning
        XCTAssertNil(errorMessage, "errorMessage is only used for rate limit warnings")
    }

    func testLoadUsesCacheIfExists_DoesNotCallNetworkWhenCached() async throws {
        // Arrange: seed cache with a small subset from JSON
        let mockPhotos = try Array(loadMockPhotosFromJSON().prefix(3))
        try encodeToCache(mockPhotos)

        // API set to failure to ensure if network is called we'd see an issue
        let mockAPI = MockUnsplashAPIClient()
        mockAPI.mode = .failure(.unknown)

        let vm: PhotoListViewModel = await MainActor.run { PhotoListViewModel(api: mockAPI) }

        // Act
        await vm.load()

        // Assert: should use cache and not attempt network (or at least not override cache)
        let photos = await MainActor.run { vm.photos }
        XCTAssertEqual(photos, mockPhotos, "Should load photos directly from cache when present")
    }

    func testShowsRateLimitWarning_WhenRemainingBelow10Percent() async throws {
        // Arrange
        let mockPhotos = try loadMockPhotosFromJSON()
        let limit = 100
        let remaining = 5 // 5% remaining -> triggers warning
        let mockAPI = MockUnsplashAPIClient()
        mockAPI.mode = .randomPhotos(.success((photos: mockPhotos, rate: RateLimitInfo(limit: limit, remaining: remaining, reset: nil))))

        let vm: PhotoListViewModel = await MainActor.run { PhotoListViewModel(api: mockAPI) }

        // Act
        await vm.load()

        // Assert
        let message = await MainActor.run { vm.errorMessage }
        XCTAssertNotNil(message, "Should display a rate limit warning")
        XCTAssertTrue(message?.contains("API rate limit low") == true, "Warning should mention low rate limit")
        XCTAssertTrue(message?.contains("\(remaining)") == true && message?.contains("\(limit)") == true, "Warning should include remaining/limit numbers")
    }

    func testRefreshClearsCacheAndReloads() async throws {
        // Arrange: initial cache
        let cached = [Photo.mock()]
        try encodeToCache(cached)

        // First API call after refresh returns a different set (from JSON)
        let mockPhotos = try loadMockPhotosFromJSON()
        let mockAPI = MockUnsplashAPIClient()
        mockAPI.mode = .randomPhotos(.success((photos: mockPhotos, rate: nil)))

        let vm: PhotoListViewModel = await MainActor.run { PhotoListViewModel(api: mockAPI) }

        // Act
        await vm.refresh()

        // Assert: cache cleared, photos reloaded from API
        let count = await MainActor.run { vm.photos.count }
        XCTAssertEqual(count, mockPhotos.count)
        // Verify cache now stores the refreshed content
        let savedData = UserDefaults.standard.data(forKey: "cachedPhotos")
        XCTAssertNotNil(savedData, "Cache should be saved after refresh load")
        if let savedData {
            let decoded = try JSONDecoder().decode([Photo].self, from: savedData)
            XCTAssertEqual(decoded.count, mockPhotos.count, "Cache should match refreshed photos")
        }
    }

    func testLoadDoesNotRefetch_WhenPhotosAlreadyPresent() async throws {
        // Arrange: Pre-populate via cache to simulate already-loaded state
        let initial = [Photo.mock()]
        try encodeToCache(initial)

        let mockAPI = MockUnsplashAPIClient()
        // If network were called it would fail; we want to ensure load bails out
        mockAPI.mode = .failure(.unknown)

        // ViewModel will load from cache in init
        let vm: PhotoListViewModel = await MainActor.run { PhotoListViewModel(api: mockAPI) }

        // Act
        await vm.load()

        // Assert
        let photos = await MainActor.run { vm.photos }
        XCTAssertEqual(photos, initial, "When photos are already loaded, load() should not refetch or alter photos")
    }
}

// MARK: - Mock Models

extension Photo {
    static func mock() -> Photo {
        Photo(
            id: "1",
            urls: PhotoURLs(
                regular: URL(string: "https://test.com/regular.jpg"),
                small: URL(string: "https://test.com/small.jpg")
            ),
            user: User(
                id: "user1",
                name: "Test User",
                profileImage: ProfileImageURLs(
                    small: URL(string: "https://test.com/small.jpg"),
                    medium: URL(string: "https://test.com/medium.jpg"),
                    large: URL(string: "https://test.com/large.jpg")
                ),
                links: UserLinks(
                    html: "https://test.com/user",
                    photos: nil,
                    portfolio: nil
                )
            ),
            exif: nil
        )
    }
}

// MARK: - Lightweight RateLimitInfo convenience init for tests

private extension RateLimitInfo {
    init(limit: Int?, remaining: Int?, reset: Date?) {
        self.init(from: HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-Ratelimit-Limit": limit != nil ? String(limit!) : "",
                "X-Ratelimit-Remaining": remaining != nil ? String(remaining!) : "",
                "X-Ratelimit-Reset": reset != nil ? String(Int(reset!.timeIntervalSince1970)) : ""
            ]
        )!)
    }
}
