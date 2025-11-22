//
//  PhotoDetailView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI
import Kingfisher

struct PhotoDetailView: View {
    
    let photo: Photo
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showInfoSheet = false
    @Environment(\.colorScheme) private var colorScheme

    private var author: Author {
        Author(
            id: photo.user.id,
            name: photo.user.name,
            imageURL: photo.user.profileImage.medium?.absoluteString ?? "",
            profileURL: photo.user.links.html
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Adaptive background
                Color(colorScheme == .dark ? .black : .systemBackground)
                    .ignoresSafeArea()

                // Centered image
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
                    }
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(colorScheme == .dark ? .black : .systemBackground), for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                .imageScale(.large)
            }

            ToolbarItem(placement: .principal) {
                Text(photo.user.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfoSheet.toggle() }) {
                    Image(systemName: "info.circle")
                }
                .imageScale(.large)
            }

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
