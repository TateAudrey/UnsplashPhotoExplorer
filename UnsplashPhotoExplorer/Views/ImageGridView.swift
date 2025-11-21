//
//  ImageGridView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

struct ImageGridView: View {
    let images: [String]

    // 2 columns grid
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
            // Preview in light mode
            ImageGridView(images: sampleImages)
                .previewDisplayName("Light Mode")
            
            // Preview in dark mode
            ImageGridView(images: sampleImages)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .previewLayout(.sizeThatFits)
    }
}
