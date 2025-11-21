//
//  DeveloperInfoView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//

import SwiftUI

struct DeveloperInfoView: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("App Developer")
                .font(.title)
                .bold()

            Text("This app was developed by Audrey Chanakira. For the purposes of the technical assessment for the iOS Developer role for SAP Mobile Start.")
                .multilineTextAlignment(.center)
                .padding()

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
