//
//  ConnectivityAlert.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI

/// A ViewModifier that shows an alert when there is no internet connection.
struct ConnectivityAlert: ViewModifier {
    
    /// Observes the shared network monitor to detect connectivity changes.
    @ObservedObject var network = NetworkMonitor.shared
    
    /// Modifies the view by presenting an alert if the device is not connected to the internet.
    /// - Parameter content: The original view content.
    /// - Returns: The view with an alert that appears when there is no network connection.
    func body(content: Content) -> some View {
        content
            .alert("No Internet Connection", isPresented: .constant(!network.isConnected)) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please check your internet connection.")
            }
    }
}

extension View {
    /// Adds a connectivity alert to any view.
    /// The alert is displayed automatically when the device is offline.
    /// - Returns: A view modified with `ConnectivityAlert`.
    func connectivityAlert() -> some View {
        self.modifier(ConnectivityAlert())
    }
}


