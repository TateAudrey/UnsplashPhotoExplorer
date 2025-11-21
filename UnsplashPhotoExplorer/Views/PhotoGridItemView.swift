//
//  PhotoGridItemView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Kingfisher

//struct PhotoGridItemView: View {
//    let url: String
//    let name: String
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            KFImage(URL(string: url))
//                .resizable()
//                .scaledToFill()
//                .clipped()
//                .frame(maxWidth: .infinity)
//            
//            LinearGradient(
//                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .frame(height: 60)
//            
//            Text(name)
//                .foregroundColor(.white)
//                .font(.subheadline)
//                .bold()
//                .padding(6)
//        }
//        .cornerRadius(8)
//    }
//}



// MARK: - Preview
//struct PhotoGridItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            PhotoGridItemView(
//                url: "https://images.unsplash.com/photo-1761839262867-af53d08b0eb5?ixlib=rb-4.1.0",
//                name: "Mountain"
//            )
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .previewDisplayName("Mountain Image")
//
//            PhotoGridItemView(
//                url: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.1.0",
//                name: "Forest"
//            )
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .previewDisplayName("Forest Image")
//        }
//    }
//}
