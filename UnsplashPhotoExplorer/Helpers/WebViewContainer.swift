//
//  WebViewContainer.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine

struct WebViewContainer: View {
    let url: URL
    @ObservedObject var viewModel: WebViewModel
    @State private var showingShareSheet = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Put the WebView under the progress bar / overlay
                WebView(viewModel: viewModel, url: url)
                    .edgesIgnoringSafeArea(.bottom)

                Divider()

                HStack {
                    Button(action: { viewModel.goBack() }) {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!viewModel.canGoBack)

                    Spacer()

                    Button(action: { viewModel.goForward() }) {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!viewModel.canGoForward)

                    Spacer()

                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }

                    Spacer()

                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .padding()
            }

            // Top linear progress indicator
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

            // Center spinner overlay while loading
            if viewModel.isLoading {
                VStack {
                    ProgressView()              // circular spinner
                        .scaleEffect(1.2)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("Loading content")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.001)) // capture taps beneath (keeps UI responsive but doesn't block)
                .zIndex(2)
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let urlToShare = viewModel.currentURL {
                ShareSheet(activityItems: [urlToShare])
            }
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .animation(.linear, value: viewModel.progress)
    }
}
