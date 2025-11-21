//
//  FavouriteAuthorView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

struct FavouriteAuthorView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var webViewModel = WebViewModel() // ← single instance

    var body: some View {
        NavigationStack {
            List {
                ForEach(appState.likedAuthors) { author in
                    NavigationLink {
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




struct FavouriteAuthorView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteAuthorView()
            .environmentObject(AppState())
    }
}
