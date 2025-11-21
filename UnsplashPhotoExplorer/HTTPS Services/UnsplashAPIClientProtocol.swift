//
//  UnsplashAPIClientProtocol.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//


/// Protocol for Unsplash API client, useful for testing and abstraction.
protocol UnsplashAPIClientProtocol {
    func fetchRandomPhotos() async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError>
    func fetchRandomPhotos(count: Int) async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError>
    func searchPhotos(query: String, page: Int, perPage: Int) async -> Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError>
}