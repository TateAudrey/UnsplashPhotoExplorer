//
//  ShareSheet.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI

/// A SwiftUI wrapper for `UIActivityViewController` to enable sharing content from SwiftUI views.
struct ShareSheet: UIViewControllerRepresentable {
    
    /// The items to share. Can include text, images, URLs, etc.
    let activityItems: [Any]
    
    /// Optional custom app-specific activities to display in the share sheet.
    let applicationActivities: [UIActivity]? = nil

    /// Creates the underlying `UIActivityViewController` instance.
    /// - Parameter context: The context provided by SwiftUI.
    /// - Returns: A configured `UIActivityViewController`.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    /// Updates the `UIActivityViewController` when SwiftUI state changes.
    /// Currently empty because the share sheet does not need dynamic updates.
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

