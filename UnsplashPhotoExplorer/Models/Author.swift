//
//  Author.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import Foundation

struct Author: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageURL: String
    let profileURL: String
}

extension Author {
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.imageURL = user.profileImage.medium?.absoluteString ?? ""
        self.profileURL = user.links.html
    }
}


