//
//  CustomScrollView.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/23.
//

import SwiftUI

struct CustomScrollbarScrollView: View {
    let items = (0..<50).map { "Item \($0)" }
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var viewportHeight: CGFloat = 1
    
    var body: some View {
        GeometryReader { outerGeo in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                    }
                )
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.contentHeight = geo.size.height
                            self.viewportHeight = outerGeo.size.height
                        }
                        return Color.clear
                    }
                )
                .padding()
            }
            .coordinateSpace(name: "scroll")
            .overlay(alignment: .trailing) {
                CustomScrollbar(
                    scrollOffset: $scrollOffset,
                    contentHeight: contentHeight,
                    viewportHeight: viewportHeight
                )
                .padding(.trailing, 2)
            }
//            .background(
//                GeometryReader { geo in
//                    Color.clear
//                        .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
//                }
//            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                print("scroll offset: \(value)")
                self.scrollOffset = -value
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomScrollbar: View {
    @Binding var scrollOffset: CGFloat
    var contentHeight: CGFloat
    var viewportHeight: CGFloat

    var body: some View {
        let scrollBarHeight = max(viewportHeight / contentHeight * viewportHeight, 30)
        let maxOffset = max(contentHeight - viewportHeight, 1)
        let y = (scrollOffset / maxOffset) * (viewportHeight - scrollBarHeight)

        return RoundedRectangle(cornerRadius: 4)
            .fill(Color.red)
            .frame(width: 4, height: scrollBarHeight)
            .offset(y: y)
            .animation(.easeInOut(duration: 0.2), value: scrollOffset)
    }
}

#Preview {
    CustomScrollbarScrollView()
}
