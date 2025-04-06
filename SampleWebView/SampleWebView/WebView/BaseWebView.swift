//
//  BaseWebView.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/06.
//

import SwiftUI
@preconcurrency import WebKit

struct BaseWebView: UIViewRepresentable {
    private let webView = WKWebView()
    let url: URL
    @ObservedObject var viewModel: CustomWebViewModel
    @Binding var title: String

    enum Action {
        case goBack
        case goForward
        case goReload
        case stopLoading
        case none
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        switch viewModel.action {
        case .goBack:
            uiView.goBack()
        case .goForward:
            uiView.goForward()
        case .goReload:
            uiView.reload()
        case .stopLoading:
            uiView.stopLoading()
        case .none:
            break
        }
        DispatchQueue.main.async {
            viewModel.action = .none
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.observations.removeAll()
    }
    
//    func loadLocalFile(webView: WKWebView, localFileName: String) {
//        let fileName = NSString(string: localFileName)
//        let pathPrefix = fileName.deletingPathExtension
//        let pathExtension = fileName.pathExtension
//
//        if let localUrl = Bundle.main.url(forResource: pathPrefix, withExtension: pathExtension) {
//            webView.loadFileURL(localUrl, allowingReadAccessTo: localUrl)
//        }
//    }
}

extension BaseWebView {
    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        private let parent: BaseWebView
        private let viewModel: CustomWebViewModel
        var observations: [NSKeyValueObservation] = []

        init(_ parent: BaseWebView, viewModel: CustomWebViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            let isLoadingObservation = parent.webView.observe(\.isLoading, options: .new, changeHandler: { _, value in
                DispatchQueue.main.async {
                    viewModel.isLoading = value.newValue ?? false
                }
            })
            observations = [
                isLoadingObservation
            ]
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let scheme = navigationAction.request.url?.scheme else {
                decisionHandler(.cancel)
                return
            }
            
            switch scheme {
            case "http", "https":
                decisionHandler(.allow)
            case "about":
                decisionHandler(.cancel)
            default:
                decisionHandler(.cancel)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.canGoBack = webView.canGoBack
            viewModel.canGoForward = webView.canGoForward
            parent.title = webView.title ?? ""
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if scrollView.contentSize.height <= scrollView.contentOffset.y + scrollView.bounds.height + 1 {
                viewModel.isBottom = true
            }
        }
    }
}
