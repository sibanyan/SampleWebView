//
//  CustomWebView.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/06.
//

import SwiftUI
import WebKit

struct CustomWebView: View {
    let urlString: String
    @ObservedObject var viewModel: CustomWebViewModel
    @State private var title: String = ""

    var body: some View {
        VStack(spacing: 0) {
            BaseWebView(url: URL(string: urlString)!, viewModel: viewModel, title: $title)
            webviewControlToolBar(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    func hiddenToolbar() -> some View {
        VStack(spacing: 0) {
            BaseWebView(url: URL(string: urlString)!, viewModel: viewModel, title: $title)
        }
    }
}

struct webviewControlToolBar: View {
    @ObservedObject var viewModel: CustomWebViewModel
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                viewModel.goBack()
            }) {
                Image(systemName: "chevron.backward")
            }
            .frame(width: 44, height: 44)
            .disabled(!viewModel.canGoBack)
            
            Button(action: {
                viewModel.goForward()
                
            }) {
                Image(systemName: "chevron.forward")
            }
            .frame(width: 44, height: 44)
            .disabled(!viewModel.canGoForward)
            
            Button(action: {
                viewModel.reloadAndStop()
            }) {
                if viewModel.isLoading {
                    Image(systemName: "xmark")
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .frame(width: 44, height: 44)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(.yellow)
    }
}

#Preview {
    CustomWebView(urlString: "https://google.com", viewModel: CustomWebViewModel())
}


