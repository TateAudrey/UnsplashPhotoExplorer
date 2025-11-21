//
//  FavouriteAuthorRow.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Kingfisher

struct FavouriteAuthorRow: View {
    let author: Author

    var body: some View {
        HStack(spacing: 16) {
            KFImage(URL(string: author.imageURL))
                .placeholder { ProgressView() }
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

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
