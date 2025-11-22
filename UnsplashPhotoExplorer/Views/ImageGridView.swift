//
//  ImageGridView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

/// A view that displays up to four images in a 2-column grid.
/// Designed for previewing or summarizing a set of images.
struct ImageGridView: View {
    
    /// Array of image URLs (as Strings) to display
    let images: [String]

    /// 2-column flexible grid layout
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(images.prefix(4), id: \.self) { url in
                }
            }
            .padding(10)
        }
    }
}

// MARK: - Preview

struct ImageGridView_Previews: PreviewProvider {
    static let sampleImages: [String] = [
        "https://picsum.photos/id/1018/400/600",
        "https://picsum.photos/id/1015/400/400",
        "https://picsum.photos/id/1016/400/500",
        "https://picsum.photos/id/1020/400/300",
        "https://picsum.photos/id/1021/400/450",
        "https://picsum.photos/id/1024/400/600",
        "https://picsum.photos/id/1027/400/350",
        "https://picsum.photos/id/1035/400/400",
        "https://picsum.photos/id/1033/400/500"
    ]

    static var previews: some View {
        Group {
            ImageGridView(images: sampleImages)
                .previewDisplayName("Light Mode")
            
            ImageGridView(images: sampleImages)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .previewLayout(.sizeThatFits)
    }
}
