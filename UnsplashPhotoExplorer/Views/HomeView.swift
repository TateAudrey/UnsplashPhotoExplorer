//
//  HomeView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/19/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = PhotoListViewModel(api: UnsplashAPIClient())
    @State private var showingDeveloperInfo = false
    
    // Adaptive grid
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.photos) { photo in
                            NavigationLink(
                                destination: PhotoDetailView(photo: photo)
                                // .environmentObject(appState)
                            ) {
                                PhotoGridItemView(
                                    url: photo.urls.small?.absoluteString ?? "",
                                    name: photo.user.name
                                )
                            }
                        }
                        
                    }
                    .padding(10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingDeveloperInfo = true
                    } label: {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .sheet(isPresented: $showingDeveloperInfo) {
                        DeveloperInfoView()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Unsplash Photo Explorer")
                        .font(.headline)
                }
            }
            .task {
               // try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s
                await viewModel.load()
            }
        }
        .serverErrorAlert()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDisplayName("HomeView Adaptive Grid")
    }
}

