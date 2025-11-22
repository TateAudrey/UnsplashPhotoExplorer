//
//  SearchView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Kingfisher

/// Main search view for browsing Unsplash photos
struct SearchView: View {
    
    @StateObject private var vm = SearchViewModel() // ViewModel managing search state
    
    // Adaptive grid layout
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                // Empty state
                if vm.filteredPhotos.isEmpty && vm.searchQuery.isEmpty {
                    VStack {
                        Spacer()
                        Text("Search your favourite photos")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    // Photo grid
                    ScrollView {
                        PhotoGrid(photos: vm.filteredPhotos) {
                            Task {
                                await vm.searchPhotos() // Load more when scrolled to bottom
                            }
                        }
                        
                        if vm.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(10)
                }
            }
            .navigationTitle("Search")
        }
        .searchable(text: $vm.searchQuery, prompt: "Search photos")
        .onChange(of: vm.searchQuery) { _, newValue in
            vm.debouncedSearch(query: newValue) // Debounce typing
        }
    }
}

/// Grid view showing photos and handling pagination
struct PhotoGrid: View {
    let photos: [Photo]
    let onScrolledToBottom: () -> Void // Triggered when last photo appears
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(photos) { photo in
                PhotoGridItemRow(photo: photo)
                    .onAppear {
                        // Trigger loading more photos when reaching the last item
                        if photo == photos.last {
                            onScrolledToBottom()
                        }
                    }
            }
        }
    }
}

/// Single photo grid item row
struct PhotoGridItemRow: View {
    let photo: Photo
    
    var body: some View {
        NavigationLink(destination: PhotoDetailView(photo: photo)) {
            PhotoGridItemView(
                url: photo.urls.small?.absoluteString ?? "",
                name: photo.user.name
            )
        }
    }
}
