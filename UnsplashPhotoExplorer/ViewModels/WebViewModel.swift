//
//  WebViewModel.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import WebKit
import Combine

/// ViewModel to manage a WKWebView in SwiftUI.
/// Tracks loading progress, navigation state, and current URL.
class WebViewModel: ObservableObject {
    
    // MARK: - Navigation State
    
    /// Whether the web view can go back
    @Published var canGoBack = false
    
    /// Whether the web view can go forward
    @Published var canGoForward = false
    
    /// The currently loaded URL
    @Published var currentURL: URL?

    // MARK: - Loading State
    
    /// Indicates whether the web view is currently loading
    @Published var isLoading: Bool = false
    
    /// Linear progress of the current page load (0.0 ... 1.0)
    @Published var progress: Double = 0.0

    /// Single WKWebView instance used by SwiftUI view
    let webView: WKWebView

    // MARK: - KVO Observers
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    private var isLoadingObserver: NSKeyValueObservation?

    // MARK: - Initialization
    
    init() {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: config)

        // Observe estimatedProgress to update progress bar
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.progress = webView.estimatedProgress
            }
        }

        // Observe isLoading to update navigation state
        isLoadingObserver = webView.observe(\.isLoading, options: [.new, .initial]) { [weak self] webView, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = webView.isLoading
                self.canGoBack = webView.canGoBack
                self.canGoForward = webView.canGoForward
                self.currentURL = webView.url
            }
        }
    }

    deinit {
        // Clear observers explicitly
        estimatedProgressObserver = nil
        isLoadingObserver = nil
    }

    // MARK: - Navigation Helpers
    
    /// Navigate back in web view history
    func goBack() { webView.goBack() }
    
    /// Navigate forward in web view history
    func goForward() { webView.goForward() }
    
    /// Reload the current page
    func refresh() { webView.reload() }
}
