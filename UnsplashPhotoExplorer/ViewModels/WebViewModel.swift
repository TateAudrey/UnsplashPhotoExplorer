//
//  WebViewModel.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import WebKit
import Combine

class WebViewModel: ObservableObject {
    // Navigation state
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var currentURL: URL?

    // Loading state
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0   // 0.0 .. 1.0

    /// Keep a single WKWebView instance
    let webView: WKWebView

    // KVO observation tokens (retain them)
    private var estimatedProgressObserver: NSKeyValueObservation?
    private var isLoadingObserver: NSKeyValueObservation?

    init() {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: config)

        // Observe estimatedProgress (KVO)
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.progress = webView.estimatedProgress
            }
        }

        // Observe isLoading (KVO) to update isLoading boolean
        isLoadingObserver = webView.observe(\.isLoading, options: [.new, .initial]) { [weak self] webView, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = webView.isLoading
                // Update navigation buttons as loading state can change navigation availability
                self.canGoBack = webView.canGoBack
                self.canGoForward = webView.canGoForward
                self.currentURL = webView.url
            }
        }
    }

    deinit {
        // Observers are automatically removed when deallocated, but explicitly nil them for clarity
        estimatedProgressObserver = nil
        isLoadingObserver = nil
    }

    // Navigation helpers
    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func refresh() { webView.reload() }
}

