//
//  SearchPhotosResponse.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//


/// Response structure for Unsplash search API.
struct SearchPhotosResponse: Codable {
    let total: Int
    let results: [Photo]
}