//
//  UnsplashError.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//

import Foundation

/// Enum representing possible errors returned by the Unsplash API.
enum UnsplashError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case httpError(statusCode: Int, message: String?)
    case rateLimited(reset: Date?, limit: Int?, remaining: Int?)
    case decodingError(Error)
    case networkError(Error)
    case unknown
}
