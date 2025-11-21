//
//  ErrorManager.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

/// A singleton class that manages and publishes error messages throughout the app.
final class ErrorManager: ObservableObject {
    
    /// Shared instance for global access.
    static let shared = ErrorManager()
    
    /// Published error message that views can observe to show alerts.
    @Published var errorMessage: String? = nil
    
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// Sets the error message based on the provided `UnsplashError`.
    /// - Parameter error: The error to be displayed.
    func show(error: UnsplashError) {
        switch error {
        case .missingAPIKey:
            errorMessage = "API key missing. Please check your configuration."
        case .invalidURL:
            errorMessage = "Invalid URL. Please try again later."
        case .httpError(_, let message):
            errorMessage = message ?? "Server returned an error."
        case .rateLimited(let reset, _, _):
            if let reset = reset {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                errorMessage = "Rate limit exceeded. Try again at \(formatter.string(from: reset))."
            } else {
                errorMessage = "Rate limit exceeded. Please wait."
            }
        case .decodingError:
            errorMessage = "Failed to parse server response."
        case .networkError:
            errorMessage = "Network error occurred. Please try again."
        case .unknown:
            errorMessage = "Something went wrong. Please try again."
        }
    }
    
    /// Clears the current error message.
    func dismiss() {
        errorMessage = nil
    }
}
