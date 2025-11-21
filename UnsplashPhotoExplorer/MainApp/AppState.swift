//
//  AppState.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Combine

/// An `ObservableObject` that manages the app-wide state for liked authors.
/// Supports fast membership checks, coalesced asynchronous saving to UserDefaults,
/// and reactive updates for SwiftUI views.
@MainActor
class AppState: ObservableObject {
    
    /// The list of liked authors. SwiftUI views observing this will update automatically.
    @Published private(set) var likedAuthors: [Author] = []

    /// Fast lookup set to check if an author is liked without scanning the array.
    private var likedAuthorIDs: Set<String> = []

    /// Key for persisting liked authors in UserDefaults.
    private let defaultsKey = "likedAuthors"

    /// Task for coalescing rapid save operations to avoid multiple writes.
    private var pendingSaveTask: Task<Void, Never>?

    /// Initializes the state by loading any previously liked authors.
    init() {
        load()
    }

    // MARK: - Persistence

    /// Loads liked authors from UserDefaults.
    private func load() {
        // Perform decoding off main thread
        Task.detached(priority: .background) { [weak self] in
            guard let self = self,
                  let data = UserDefaults.standard.data(forKey: self.defaultsKey),
                  let decoded = try? JSONDecoder().decode([Author].self, from: data) else { return }

            await MainActor.run {
                self.likedAuthors = decoded
                self.likedAuthorIDs = Set(decoded.map { $0.id })
            }
        }
    }

    /// Saves liked authors asynchronously with coalescing to prevent multiple rapid writes.
    private func save() {
        // Cancel any in-flight save to avoid queueing multiple writes
        pendingSaveTask?.cancel()

        // Capture a snapshot on the MainActor
        let snapshot = likedAuthors

        pendingSaveTask = Task.detached(priority: .background) { [defaultsKey] in
            guard let encoded = try? JSONEncoder().encode(snapshot) else { return }
            // Safe to write UserDefaults off the main thread
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    // MARK: - Author Management

    /// Adds or removes an author from likedAuthors. Toggles their status.
    /// - Parameter author: The `Author` to toggle.
    func toggleAuthor(_ author: Author) {
        if likedAuthorIDs.contains(author.id) {
            likedAuthors.removeAll { $0.id == author.id }
            likedAuthorIDs.remove(author.id)
        } else {
            likedAuthors.append(author)
            likedAuthorIDs.insert(author.id)
        }
        save()
    }

    /// Checks if an author is currently liked.
    /// - Parameter author: The `Author` to check.
    /// - Returns: `true` if the author is liked.
    func isAuthorLiked(_ author: Author) -> Bool {
        likedAuthorIDs.contains(author.id)
    }

    /// Removes a specific author from likedAuthors.
    /// - Parameter author: The `Author` to remove.
    func removeAuthor(_ author: Author) {
        likedAuthors.removeAll { $0.id == author.id }
        likedAuthorIDs.remove(author.id)
        save()
    }

    // MARK: - Convenience

    /// Returns `true` if there are any liked authors.
    var hasLikes: Bool {
        !likedAuthors.isEmpty
    }
}
