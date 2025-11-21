//
//  WebViewContainer.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

/// A SwiftUI container view that displays a WebView with navigation controls, a loading indicator,
/// progress bar, and a share button.
struct WebViewContainer: View {
    
    /// The URL to load in the WebView.
    let url: URL
    
    /// The WebViewModel that handles WebView state and actions.
    @ObservedObject var viewModel: WebViewModel
    
    /// State to control presentation of the share sheet.
    @State private var showingShareSheet = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // WebView that displays the webpage content
                WebView(viewModel: viewModel, url: url)
                    .edgesIgnoringSafeArea(.bottom)

                Divider()

                // Navigation toolbar
                HStack {
                    // Back button
                    Button(action: { viewModel.goBack() }) {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!viewModel.canGoBack)

                    Spacer()

                    // Forward button
                    Button(action: { viewModel.goForward() }) {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!viewModel.canGoForward)

                    Spacer()

                    // Refresh button
                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }

                    Spacer()

                    // Share button
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .padding()
            }

            // Linear progress bar at the top while page is loading
            if viewModel.progress > 0 && viewModel.progress < 1 {
                VStack {
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 2)
                        .padding(.horizontal, 0)
                    Spacer()
                }
                .transition(.opacity)
                .zIndex(1)
            }

            // Center circular spinner overlay while loading
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("Loading content")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.001)) // captures taps without blocking UI
                .zIndex(2)
                .transition(.opacity)
            }
        }
        // Present the share sheet when the user taps the share button
        .sheet(isPresented: $showingShareSheet) {
            if let urlToShare = viewModel.currentURL {
                ShareSheet(activityItems: [urlToShare])
            }
        }
        // Animate loading state changes and progress updates
        .animation(.easeInOut, value: viewModel.isLoading)
        .animation(.linear, value: viewModel.progress)
    }
}
