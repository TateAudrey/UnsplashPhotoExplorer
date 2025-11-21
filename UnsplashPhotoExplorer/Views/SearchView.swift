//
//  SearchView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.filteredPhotos.isEmpty && vm.searchQuery.isEmpty {
                    VStack {
                        Spacer()
                        Text("Search your favourite photos")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        PhotoGrid(photos: vm.filteredPhotos) {
                            Task {
                                await vm.searchPhotos()
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
            vm.debouncedSearch(query: newValue)
        }
    }
}

struct PhotoGrid: View {
    let photos: [Photo]
    let onScrolledToBottom: () -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(photos) { photo in
                PhotoGridItemRow(photo: photo)
                    .onAppear {
                        if photo == photos.last {
                            onScrolledToBottom()
                        }
                    }
            }
        }
    }
}

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
