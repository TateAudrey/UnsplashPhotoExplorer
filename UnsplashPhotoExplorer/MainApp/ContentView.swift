//
//  ContentView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

/// The main entry view of the app with a tab-based interface.
/// Dynamically shows the "Likes" tab based on AppState.
struct ContentView: View {
    
    /// Access to the global app state for liked authors.
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            // Home tab showing photos or main content
            Tab("Home", systemImage: "photo.fill") {
                HomeView()
            }

            // Likes tab only appears if there are liked authors
            if appState.hasLikes {
                Tab("Likes", systemImage: "heart.fill") {
                    FavouriteAuthorView()
                }
            }

            // Search tab
            Tab(role: .search) {
                SearchView()
            }
        }
    }
}

#Preview {
    ContentView()
}
