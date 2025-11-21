//
//  ServerErrorAlert.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI

/// A ViewModifier that displays an alert for server or API errors using ErrorManager.
struct ServerErrorAlert: ViewModifier {
    
    /// Observes the shared ErrorManager singleton to reactively display error messages.
    @ObservedObject var errorManager = ErrorManager.shared
    
    /// Modifies the view to show an alert when `errorManager.errorMessage` is not nil.
    /// - Parameter content: The original view content.
    /// - Returns: The view with a reactive error alert.
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: Binding<Bool>(
                    get: { errorManager.errorMessage != nil }, // Show alert if there is an error
                    set: { _ in errorManager.dismiss() }       // Dismiss alert on user action
                )
            ) {
                Button("OK", role: .cancel) {
                    errorManager.dismiss()
                }
            } message: {
                Text(errorManager.errorMessage ?? "Something went wrong")
            }
    }
}

extension View {
    /// Adds a server error alert to any view.
    /// The alert will automatically appear whenever `ErrorManager.shared.errorMessage` is set.
    /// - Returns: The view modified with `ServerErrorAlert`.
    func serverErrorAlert() -> some View {
        self.modifier(ServerErrorAlert())
    }
}

