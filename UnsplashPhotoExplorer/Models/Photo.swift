//
//  Photo.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation

/// Represents a photo from Unsplash API.
/// Conforms to `Identifiable` for SwiftUI lists, `Codable` for JSON decoding/persistence,
/// and `Equatable` for comparison.
struct Photo: Identifiable, Codable, Equatable {
    let id: String           // Unique photo ID
    let urls: PhotoURLs      // Different sizes of photo URLs
    let user: User           // Author/user who uploaded the photo
    let exif: Exif?          // Optional EXIF metadata
}

/// Contains URL links for different image sizes.
struct PhotoURLs: Codable, Equatable {
    let regular: URL?        // Regular size image URL
    let small: URL?          // Small size image URL
}

/// Represents a user/author in Unsplash.
struct User: Codable, Equatable {
    let id: String                       // User ID
    let name: String                     // User display name
    let profileImage: ProfileImageURLs   // Profile image URLs
    let links: UserLinks                 // Links to user’s profile, photos, and portfolio
}

/// URLs for the user's various pages on Unsplash.
struct UserLinks: Codable, Equatable {
    let html: String       // Profile page URL
    let photos: String?    // Optional photos page URL
    let portfolio: String? // Optional portfolio page URL
}

/// URLs for the user's profile image in different sizes.
struct ProfileImageURLs: Codable, Equatable {
    let small: URL?  // Small avatar
    let medium: URL? // Medium avatar
    let large: URL?  // Large avatar
}

/// Represents optional EXIF metadata for a photo.
struct Exif: Codable, Equatable {
    let make: String?         // Camera manufacturer
    let model: String?        // Camera model
    let name: String?         // Optional EXIF name
    let exposureTime: String? // Exposure time (shutter speed)
    let aperture: String?     // Aperture value
    let focalLength: String?  // Focal length
    let iso: Int?             // ISO value
}
