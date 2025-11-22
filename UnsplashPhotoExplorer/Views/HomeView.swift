//
//  HomeView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

/// Main home screen displaying a grid of Unsplash photos.
/// Supports navigation to photo details, developer info sheet, and error handling.
struct HomeView: View {
    
    /// ViewModel handling photo fetching, caching, and state
    @StateObject private var viewModel = PhotoListViewModel(api: UnsplashAPIClient())
    
    /// Controls the presentation of the developer info sheet
    @State private var showingDeveloperInfo = false
    
    /// Adaptive grid layout
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Loading state
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Error message state
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                
                // Display photos in adaptive grid
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.photos) { photo in
                            NavigationLink(
                                destination: PhotoDetailView(photo: photo)
                            ) {
                                PhotoGridItemView(
                                    url: photo.urls.small?.absoluteString ?? "",
                                    name: photo.user.name
                                )
                            }
                        }
                    }
                    .padding(10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Developer info button (logo)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingDeveloperInfo = true
                    } label: {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .sheet(isPresented: $showingDeveloperInfo) {
                        DeveloperInfoView()
                    }
                }
                
                // Title in toolbar
                ToolbarItem(placement: .principal) {
                    Text("Unsplash Photo Explorer")
                        .font(.headline)
                }
            }
            .task {
                // Load photos asynchronously when view appears
                await viewModel.load()
            }
        }
        // Global server error alert
        .serverErrorAlert()
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDisplayName("HomeView Adaptive Grid")
    }
}

