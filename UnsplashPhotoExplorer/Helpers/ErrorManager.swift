//
//  ErrorManager.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

final class ErrorManager: ObservableObject {
    static let shared = ErrorManager()  // singleton for global access
    
    @Published var errorMessage: String? = nil
    
    private init() {}
    
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
    
    func dismiss() {
        errorMessage = nil
    }
}
