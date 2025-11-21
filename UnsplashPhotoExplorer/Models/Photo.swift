//
//  Photo.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation

struct Photo: Identifiable, Codable, Equatable {
    let id: String
    let urls: PhotoURLs
    let user: User
    let exif: Exif?
}

struct PhotoURLs: Codable, Equatable {
    let regular: URL?
    let small: URL?
}

struct User: Codable, Equatable {
    let id: String
    let name: String
    let profileImage: ProfileImageURLs
    let links: UserLinks
}

struct UserLinks: Codable, Equatable {
    let html: String
    let photos: String?
    let portfolio: String?
}

struct ProfileImageURLs: Codable, Equatable {
    let small: URL?
    let medium: URL?
    let large: URL?
}

struct Exif: Codable, Equatable {
    let make: String?
    let model: String?
    let name: String?
    let exposureTime: String?
    let aperture: String?
    let focalLength: String?
    let iso: Int?
}
