//
//  ContentView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            Tab("Home", systemImage: "photo.fill") {
                HomeView()
            }

            if appState.hasLikes {
                Tab("Likes", systemImage: "heart.fill") {
                    FavouriteAuthorView()
                }
            }

            Tab(role: .search) {
                SearchView()
            }
        }
    }
}




#Preview {
    ContentView()
}
