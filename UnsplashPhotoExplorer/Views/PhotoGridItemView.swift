//
//  PhotoGridItemView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Kingfisher

struct PhotoGridItemView: View {
    let url: String
    let name: String

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                
                KFImage(URL(string: url))
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: geo.size.width, height: 150)
                    

                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.85)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .clipped()

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
        .frame(height: 150) // Fallback min height
    }
}

struct PhotoGridItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhotoGridItemView(
                url: "https://images.unsplash.com/photo-1761839262867-af53d08b0eb5?ixid=M3w4MzIzOTN8MXwxfGFsbHwxfHx8fHx8fHwxNzYzNTg0ODA3fA&ixlib=rb-4.1.0",
                name: "Mountain"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Mountain Image")

            PhotoGridItemView(
                url: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixid=M3w4MzIzOTN8MXwxfGFsbHwxfHx8fHx8fHwxNzYzNTg0ODA3fA&ixlib=rb-4.1.0",
                name: "Forest"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Forest Image")
        }
    }
}
