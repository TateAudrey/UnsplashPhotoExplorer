//
//  LikedAuthorsStore.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

class LikedAuthorsStore: ObservableObject {
    
    @Published private(set) var likedAuthors: [Author] = []

    private let defaultsKey = "likedAuthors"

    init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        if let loaded = try? JSONDecoder().decode([Author].self, from: data) {
            likedAuthors = loaded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(likedAuthors) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    func add(author: Author) {
        if !likedAuthors.contains(where: { $0.id == author.id }) {
            likedAuthors.append(author)
            save()
        }
    }

    func remove(author: Author) {
        likedAuthors.removeAll(where: { $0.id == author.id })
        save()
    }
}
