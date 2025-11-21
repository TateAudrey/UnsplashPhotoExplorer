//
//  PhotoDetailView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Kingfisher

struct PhotoDetailView: View {

    let photo: Photo  // Full photo object

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showInfoSheet = false

    // Cache the author once for this view instance
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
            // Image with Kingfisher placeholder
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

            // Title
            ToolbarItem(placement: .principal) {
                Text(photo.user.name)
                    .font(.headline)
                    .lineLimit(1)
            }

            // Info button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfoSheet.toggle() }) {
                    Image(systemName: "info.circle")
                }
                .imageScale(.large)
            }

            // Like button
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
        .sheet(isPresented: $showInfoSheet) {
            PhotoInfoSheet(photo: photo)
                .presentationDetents([.medium, .large])
        }
    }
}

