//
//  PhotoGridItemView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Kingfisher

/// A single photo item in a grid, showing an image with the author/description overlay.
struct PhotoGridItemView: View {
    
    /// Image URL as string
    let url: String
    
    /// Text to overlay (usually photo author or description)
    let name: String

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                
                // Main image
                KFImage(URL(string: url))
                    .placeholder { Color.gray.opacity(0.2) }  // Shimmer/placeholder
                    .cacheOriginalImage()                      // Kingfisher caching
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: geo.size.width, height: 150)
                
                // Gradient overlay at bottom for text readability
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.85)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .clipped()

                // Text overlay (author or photo name)
                Text(name)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .frame(height: 150) // Ensures uniform height
    }
}

// MARK: - Preview
struct PhotoGridItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhotoGridItemView(
                url: "https://images.unsplash.com/photo-1761839262867-af53d08b0eb5?ixlib=rb-4.1.0",
                name: "Mountain"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Mountain Image")

            PhotoGridItemView(
                url: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.1.0",
                name: "Forest"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Forest Image")
        }
    }
}
