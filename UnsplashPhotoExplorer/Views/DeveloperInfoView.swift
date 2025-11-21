//
//  DeveloperInfoView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//

import SwiftUI

/// A simple SwiftUI view displaying information about the app developer.
/// Used to show credits or additional context, with a dismiss button.
struct DeveloperInfoView: View {
    
    /// Environment value to dismiss the current view (for modals or sheets)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("App Developer")
                .font(.title)
                .bold()

            // Description / context
            Text("This app was developed by Audrey Chanakira. For the purposes of the technical assessment for the iOS Developer role for SAP Mobile Start.")
                .multilineTextAlignment(.center)
                .padding()

            // Close button to dismiss the view
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

