//
//  WebView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine
import WebKit

/// SwiftUI wrapper around WKWebView to display web content
/// Uses a shared WebView instance from a WebViewModel
struct WebView: UIViewRepresentable {
    
    @ObservedObject var viewModel: WebViewModel
    
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        // Assign the coordinator as the navigation delegate
        viewModel.webView.navigationDelegate = context.coordinator

        // Load the initial URL request
        viewModel.webView.load(URLRequest(url: url))

        // Return the single shared WKWebView
        return viewModel.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No-op: The same WKWebView instance is reused and updated via KVO in WebViewModel
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    /// Coordinator class to handle WKWebView navigation callbacks
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        let viewModel: WebViewModel

        init(_ parent: WebView, viewModel: WebViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        // Called when a navigation starts
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.viewModel.isLoading = true
            }
        }

        // Called when navigation finishes successfully
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.viewModel.canGoBack = webView.canGoBack
                self.viewModel.canGoForward = webView.canGoForward
                self.viewModel.currentURL = webView.url
                self.viewModel.isLoading = webView.isLoading
            }
        }

        // Handle navigation failures
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.viewModel.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.viewModel.isLoading = false
            }
        }
    }
}
