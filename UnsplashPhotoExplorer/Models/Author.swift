//
//  Author.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import Foundation

/// Represents an author/user in the app.
/// Conforms to `Identifiable` for use in SwiftUI lists,
/// `Codable` for persistence, and `Equatable` for comparison.
struct Author: Identifiable, Codable, Equatable {
    
    /// Unique identifier for the author
    let id: String
    
    /// The author's display name
    let name: String
    
    /// URL string for the author's profile image
    let imageURL: String
    
    /// URL string for the author's Unsplash profile page
    let profileURL: String
}

// MARK: - Convenience Initializer

extension Author {
    /// Initializes an `Author` from a `User` object (e.g., Unsplash API user model)
    /// - Parameter user: The `User` object from which to create an `Author`
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.imageURL = user.profileImage.medium?.absoluteString ?? ""
        self.profileURL = user.links.html
    }
}



