//
//  FavouriteAuthorRow.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Kingfisher

/// A row view that displays information about a favourite author,
/// including their profile image, name, and label.
/// Designed for use in lists  of authors.
struct FavouriteAuthorRow: View {
    
    /// The author to display
    let author: Author

    var body: some View {
        HStack(spacing: 16) {
            // Profile image loaded asynchronously using Kingfisher
            KFImage(URL(string: author.imageURL))
                .placeholder { ProgressView() } // Show spinner while loading
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Author details
            VStack(alignment: .leading, spacing: 6) {
                Text("Author")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(author.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.label))
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
    }
}

// MARK: - Previews

struct FavouriteAuthorRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FavouriteAuthorRow(
                author: Author(
                    id: "author_1",
                    name: "Annie Leibovitz",
                    imageURL: "https://picsum.photos/id/1011/200/200",
                    profileURL: ""
                )
            )
            .previewDisplayName("Light")

            FavouriteAuthorRow(
                author: Author(
                    id: "author_2",
                    name: "Steve McCurry",
                    imageURL: "https://picsum.photos/id/1011/200/200",
                    profileURL: ""
                )
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
