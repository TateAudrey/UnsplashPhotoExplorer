//
//  AppState.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    
    @Published private(set) var likedAuthors: [Author] = []
    // Fast membership checks to avoid repeated linear scans
    private var likedAuthorIDs: Set<String> = []

    private let defaultsKey = "likedAuthors"

    // Coalesced async saving
    private var pendingSaveTask: Task<Void, Never>?

    init() {
        load()
    }

    // Load from UserDefaults
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        if let decoded = try? JSONDecoder().decode([Author].self, from: data) {
            likedAuthors = decoded
            likedAuthorIDs = Set(decoded.map { $0.id })
        }
    }

    // Coalesce and move the encoding/write off the main actor
    private func save() {
        // Cancel any in-flight save so rapid taps don't queue many writes
        pendingSaveTask?.cancel()

        // Capture a snapshot on the MainActor
        let snapshot = likedAuthors

        pendingSaveTask = Task.detached(priority: .background) { [defaultsKey] in
            guard let encoded = try? JSONEncoder().encode(snapshot) else { return }
            // UserDefaults is thread-safe for set(_:forKey:); doing this off main avoids UI stalls
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    // Add/remove author
    func toggleAuthor(_ author: Author) {
        if likedAuthorIDs.contains(author.id) {
            likedAuthors.removeAll(where: { $0.id == author.id })
            likedAuthorIDs.remove(author.id)
        } else {
            likedAuthors.append(author)
            likedAuthorIDs.insert(author.id)
        }
        // Persist asynchronously without blocking the UI thread
        save()
    }

    func isAuthorLiked(_ author: Author) -> Bool {
        likedAuthorIDs.contains(author.id)
    }

    // Show Likes tab only when needed
    var hasLikes: Bool {
        !likedAuthors.isEmpty
    }
    
    func removeAuthor(_ author: Author) {
        likedAuthors.removeAll { $0.id == author.id }
        save()
    }

}
