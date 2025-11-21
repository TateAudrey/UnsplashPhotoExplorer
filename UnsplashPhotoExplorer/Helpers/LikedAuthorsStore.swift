//
//  LikedAuthorsStore.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

/// A store that manages a list of liked authors and persists them using UserDefaults.
class LikedAuthorsStore: ObservableObject {
    
    /// The list of liked authors. SwiftUI views can observe changes to this array.
    @Published private(set) var likedAuthors: [Author] = []

    /// Key used for storing liked authors in UserDefaults.
    private let defaultsKey = "likedAuthors"

    /// Initializes the store and loads any previously saved liked authors.
    init() {
        load()
    }

    /// Loads the liked authors from UserDefaults.
    func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        if let loaded = try? JSONDecoder().decode([Author].self, from: data) {
            likedAuthors = loaded
        }
    }

    /// Saves the current list of liked authors to UserDefaults.
    func save() {
        if let encoded = try? JSONEncoder().encode(likedAuthors) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    /// Adds a new author to the liked authors list if not already present.
    /// - Parameter author: The `Author` object to add.
    func add(author: Author) {
        if !likedAuthors.contains(where: { $0.id == author.id }) {
            likedAuthors.append(author)
            save()
        }
    }

    /// Removes an author from the liked authors list.
    /// - Parameter author: The `Author` object to remove.
    func remove(author: Author) {
        likedAuthors.removeAll(where: { $0.id == author.id })
        save()
    }
}
