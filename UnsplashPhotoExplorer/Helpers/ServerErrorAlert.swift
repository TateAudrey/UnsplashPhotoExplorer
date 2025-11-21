//
//  ServerErrorAlert.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI

struct ServerErrorAlert: ViewModifier {
    
    @ObservedObject var errorManager = ErrorManager.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorManager.errorMessage != nil },
                set: { _ in errorManager.dismiss() }
            )) {
                Button("OK", role: .cancel) {
                    errorManager.dismiss()
                }
            } message: {
                Text(errorManager.errorMessage ?? "Something went wrong")
            }
    }
}

extension View {
    func serverErrorAlert() -> some View {
        self.modifier(ServerErrorAlert())
    }
}

