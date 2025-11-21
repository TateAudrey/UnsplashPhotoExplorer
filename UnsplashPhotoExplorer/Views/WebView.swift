//
//  WebView.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import SwiftUI
import Combine
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        // assign coordinator as delegate so it receives navigation callbacks
        viewModel.webView.navigationDelegate = context.coordinator

        // load initial request
        viewModel.webView.load(URLRequest(url: url))

        return viewModel.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // no-op: we reuse the same webView instance in the viewModel
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        let viewModel: WebViewModel

        init(_ parent: WebView, viewModel: WebViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        // called when navigation starts (provisional)
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.viewModel.isLoading = true
            }
        }

        // called when navigation finishes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.viewModel.canGoBack = webView.canGoBack
                self.viewModel.canGoForward = webView.canGoForward
                self.viewModel.currentURL = webView.url
                self.viewModel.isLoading = webView.isLoading // normally false here
            }
        }

        // handle failures (hide loading indicator)
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
