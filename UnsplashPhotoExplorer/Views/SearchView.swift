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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                content(for: geo.size)
            }
            .navigationTitle("Search")
        }
        .searchable(text: $vm.searchQuery, prompt: "Search photos")
        .onChange(of: vm.searchQuery) { _, newValue in
            vm.debouncedSearch(query: newValue)
        }
    }
    
    // MARK: - Content Builder
    @ViewBuilder
    private func content(for size: CGSize) -> some View {
        let spacing: CGFloat = 10
        let horizontalPadding: CGFloat = 10
        let isPadLike = UIDevice.current.userInterfaceIdiom == .pad || size.width > 900
        let columnsCount = isPadLike ? 4 : 2
        let totalSpacing = CGFloat(columnsCount - 1) * spacing + horizontalPadding * 2
        let columnWidth = floor((size.width - totalSpacing) / CGFloat(columnsCount))
        
        if vm.filteredPhotos.isEmpty && vm.searchQuery.isEmpty {
            VStack {
                Spacer()
                Text("Search your favourite photos")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: spacing), count: columnsCount),
                    spacing: spacing
                ) {
                    ForEach(vm.filteredPhotos) { photo in
                        PhotoGridItemRow(photo: photo, width: columnWidth)
                            .onAppear {
                                if photo == vm.filteredPhotos.last {
                                    Task { await vm.searchPhotos() }
                                }
                            }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 10)
                
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Grid Row
struct PhotoGridItemRow: View {
    let photo: Photo
    let width: CGFloat
    
    var body: some View {
        NavigationLink(destination: PhotoDetailView(photo: photo)) {
            PhotoGridItemView(
                url: photo.urls.small?.absoluteString ?? "",
                name: photo.user.name, width: width
            )
            .frame(width: width)
            .aspectRatio(0.75, contentMode: .fit)
        }
    }
}

// MARK: - Grid Item
struct PhotoGridItemView: View {
    let url: String
    let name: String
    let width: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: url))
                .placeholder { Color.gray.opacity(0.2) }
                .cacheOriginalImage()
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width * 0.75)
                .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            
            Text(name)
                .foregroundColor(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(6)
        }
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
