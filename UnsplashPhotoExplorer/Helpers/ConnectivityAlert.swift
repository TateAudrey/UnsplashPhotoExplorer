//
//  ConnectivityAlert.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI

struct ConnectivityAlert: ViewModifier {
    
    @ObservedObject var network = NetworkMonitor.shared
    
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
    func connectivityAlert() -> some View {
        self.modifier(ConnectivityAlert())
    }
}

