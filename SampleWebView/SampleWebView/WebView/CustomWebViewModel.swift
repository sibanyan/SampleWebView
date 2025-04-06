//
//  CustomWebViewModel.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/06.
//

import Foundation

class CustomWebViewModel: ObservableObject {
    @Published var isBottom = false
    @Published var isLoading: Bool = false
    @Published var action: BaseWebView.Action = .none
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    func goBack() {
        action = .goBack
    }
    
    func goForward() {
        action = .goForward
    }

    func reloadAndStop() {
        if isLoading {
            action = .stopLoading
        } else {
            action = .goReload
        }
    }
}
