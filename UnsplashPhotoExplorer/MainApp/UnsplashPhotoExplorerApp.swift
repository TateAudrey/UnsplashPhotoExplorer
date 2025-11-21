//
//  UnsplashPhotoExplorerApp.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

@main
struct UnsplashPhotoExplorerApp: App {
    
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .connectivityAlert()
        }
    }
}

