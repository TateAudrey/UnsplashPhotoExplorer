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
        GridItem(.adaptive(minimum: UIDevice.current.userInterfaceIdiom == .pad ? 280 : 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                // configuration
                let horizontalPadding: CGFloat = 10
                let spacing: CGFloat = 10

                // decide columns: 4 for iPad / regular horizontal size class, else 2
                let isPadLike = UIDevice.current.userInterfaceIdiom == .pad || (geo.size.width > 900)
                let columnsCount = isPadLike ? 4 : 2

                let totalSpacing = spacing * CGFloat(columnsCount - 1) + (horizontalPadding * 2)
                let columnWidth = floor((geo.size.width - totalSpacing) / CGFloat(columnsCount))

                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 40)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: spacing), count: columnsCount),
                            spacing: spacing
                        ) {
                            ForEach(viewModel.photos) { photo in
                                NavigationLink(
                                    destination: PhotoDetailView(photo: photo)
                                ) {
                                    PhotoGridItemView(
                                        url: photo.urls.small?.absoluteString ?? "",
                                        name: photo.user.name, width: columnWidth
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 10)
                    }
                }
            }            .navigationBarTitleDisplayMode(.inline)
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

