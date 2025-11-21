//
//  PhotoDetailView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Kingfisher

import SwiftUI
import Kingfisher

/// View displaying a single photo in full size along with author details, like button, and info sheet.
struct PhotoDetailView: View {

    /// Full photo object to display
    let photo: Photo

    /// App-wide state for liked authors
    @EnvironmentObject var appState: AppState

    /// Environment dismiss function to close this view
    @Environment(\.dismiss) private var dismiss

    /// Controls presentation of photo info sheet
    @State private var showInfoSheet = false

    /// Cached Author object for this photo
    private var author: Author {
        Author(
            id: photo.user.id,
            name: photo.user.name,
            imageURL: photo.user.profileImage.medium?.absoluteString ?? "",
            profileURL: photo.user.links.html
        )
    }

    var body: some View {
        ZStack {
            // Display the photo using Kingfisher
            KFImage(photo.urls.regular)
                .resizable()
                .cacheOriginalImage()
                .placeholder {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                    }
                    .ignoresSafeArea()
                }
                .scaledToFit()
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                .imageScale(.large)
            }

            // Title showing author name
            ToolbarItem(placement: .principal) {
                Text(photo.user.name)
                    .font(.headline)
                    .lineLimit(1)
            }

            // Info sheet button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfoSheet.toggle() }) {
                    Image(systemName: "info.circle")
                }
                .imageScale(.large)
            }

            // Like / favorite button
            ToolbarItem(placement: .navigationBarTrailing) {
                let isLiked = appState.isAuthorLiked(author)
                Button(action: {
                    withAnimation(.spring()) {
                        appState.toggleAuthor(author)
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .primary)
                }
            }
        }
        // Present info sheet for the photo
        .sheet(isPresented: $showInfoSheet) {
            PhotoInfoSheet(photo: photo)
                .presentationDetents([.medium, .large])
        }
    }
}
