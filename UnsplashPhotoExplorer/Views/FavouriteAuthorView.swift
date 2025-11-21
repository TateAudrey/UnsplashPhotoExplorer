//
//  FavouriteAuthorView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

/// View displaying a list of the user's favourite authors.
/// Allows navigation to the author’s profile in a web view and deletion from the favourites list.
struct FavouriteAuthorView: View {
    
    /// Shared app state containing liked authors
    @EnvironmentObject var appState: AppState
    
    /// Single instance of WebViewModel for navigation
    @StateObject private var webViewModel = WebViewModel()

    var body: some View {
        NavigationStack {
            List {
                // Iterate over liked authors
                ForEach(appState.likedAuthors) { author in
                    NavigationLink {
                        // Navigate to WebView showing author's profile
                        if let url = URL(string: author.profileURL) {
                            WebViewContainer(url: url, viewModel: webViewModel)
                        } else {
                            Text("Invalid profile URL")
                        }
                    } label: {
                        FavouriteAuthorRow(author: author)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    // Handle swipe-to-delete with animation
                    let authorsToRemove = indexSet.map { appState.likedAuthors[$0] }
                    withAnimation(.easeInOut) {
                        for author in authorsToRemove {
                            appState.removeAuthor(author)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Favourite Authors")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Preview

struct FavouriteAuthorView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteAuthorView()
            .environmentObject(AppState())
    }
}
