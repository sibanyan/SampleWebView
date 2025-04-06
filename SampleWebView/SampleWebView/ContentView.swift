//
//  ContentView.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: CustomWebViewModel = CustomWebViewModel()

    var body: some View {
        CustomWebView(urlString: "https://google.com", viewModel: viewModel)
            .hiddenToolbar()
            .alert("画面一番下までいった", isPresented: $viewModel.isBottom) {
                Button(action: {}) {
                    Text("OK")
                }
            }
    }
}

#Preview {
    ContentView()
}
