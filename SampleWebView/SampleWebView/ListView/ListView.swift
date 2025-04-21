//
//  ListView.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/21.
//

import SwiftUI

struct ListView : View {
    let contacts: [Contact]
//    @State private var currentSection: String? = nil
    @State private var isIndicatorVisible: Bool = false
    @State private var sectionOffsets: [String: CGFloat] = [:]
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        let grouped = groupContacts(contacts)
        let sortedKeys = grouped.keys.sorted {
            if $0 == "#" { return false }
            if $1 == "#" { return true }
            return $0 < $1
        }

        GeometryReader { outerProxy in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    GeometryReader { scrollGeo in
                        Color.clear
                            .onAppear {
                                scrollOffset = scrollGeo.frame(in: .named("scroll")).minY
                            }
                            .onChange(of: scrollGeo.frame(in: .named("scroll")).minY) { newY in
                                print("scrollOffset\(scrollOffset)")
                                isIndicatorVisible = true
                                scrollOffset = -newY
                                // 自動でフェードアウト
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    withAnimation {
                                        self.isIndicatorVisible = false
                                    }
                                }
                            }
                    }
                    .frame(height: 0) // 見えない位置に設置

                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(sortedKeys, id: \.self) { key in
                            sectionView(key: key, contacts: grouped[key] ?? [])
                                .background(GeometryReader { geo in
                                    Color
                                        .clear
                                        .onAppear {
                                            sectionOffsets[key] = geo.frame(in: .named("scroll")).minY
                                        }
                                        .onChange(of: geo.frame(in: .named("scroll")).minY) { value in
//                                            print("key:\(key),value\(value)")
                                            sectionOffsets[key] = value

                                        }
                                })
                        }
                    }
                    .padding(.horizontal)
                }
                .coordinateSpace(name: "scroll")
                .overlay(alignment: .topTrailing) {
                    if let key = findCurrentSection(), let y = sectionOffsets[key], isIndicatorVisible {
                        Text(key)
                            .font(.headline)
                            .padding(30)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .offset(x: -10, y: scrollOffset / 1.8)
                            .animation(.easeOut(duration: 0.1), value: key)
                    }
                }
            }
        }
    }

    /// 現在のセクションを判定
    func findCurrentSection() -> String? {
        let visible = sectionOffsets.min { abs($0.value - scrollOffset) < abs($1.value - scrollOffset) }
        return visible?.key
    }
    
    func sectionView(key: String, contacts: [Contact]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // section
            Text(key).font(.title2).bold().padding(.top, 8)
            // content
            ForEach(contacts) { contact in
                // cell
                Text(contact.name).padding(.leading, 16)
            }
        }
    }
//    var body: some View {
//
//        let grouped = groupContacts(contacts)
//        let sortedKeys = grouped.keys.sorted { lhs, rhs in
//            if lhs == "#" { return false }
//            if rhs == "#" { return true }
//            return lhs < rhs
//        }
//        ScrollViewReader { scrollProxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 12) {
//                    ForEach(sortedKeys, id: \.self) { key in
//                        SectionView(key: key, contacts: grouped[key] ?? [])
//                            .background(GeometryReader { geo in
//                                Color.clear
//                                    .preference(key: SectionPreferenceKey.self, value: [SectionInfo(key: key, offset: geo.frame(in: .named("scroll")).minY)])
//                            })
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .coordinateSpace(name: "scroll")
//            .onPreferenceChange(SectionPreferenceKey.self) { values in
//                updateCurrentSection(with: values)
//            }
//            .overlay(
//                Group {
//                    if let current = currentSection, isIndicatorVisible {
//                        Text(current)
//                            .font(.largeTitle)
//                            .padding(20)
//                            .background(Color.gray.opacity(0.8))
//                            .cornerRadius(12)
//                            .foregroundColor(.white)
//                            .transition(.opacity)
//                            .animation(.easeInOut, value: current)
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            )
//        }
//
//    }
//    
//    private func updateCurrentSection(with sectionOffsets: [SectionInfo]) {
//        
//        guard let scrollY = UIApplication.shared.windows.first?.rootViewController?.view.frame.minY else { return }
//
//        let visible = sectionOffsets
//            .sorted { abs($0.offset - scrollY) < abs($1.offset - scrollY) }
//            .first
//
//        if let visible = visible, visible.key != currentSection {
//            currentSection = visible.key
//            isIndicatorVisible = true
//
//            // 自動でフェードアウト
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                withAnimation {
//                    self.isIndicatorVisible = false
//                }
//            }
//        }
//    }
}

// MARK: - SectionView
struct SectionView: View {
    let key: String
    let contacts: [Contact]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(key)
                .font(.title2)
                .bold()
                .padding(.top, 8)

            ForEach(contacts) { contact in
                Text(contact.name)
                    .padding(.leading, 16)
            }
        }
    }
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
}

func groupContacts(_ contacts: [Contact]) -> [String: [Contact]] {
    var grouped: [String: [Contact]] = [:]

    for contact in contacts {
        let name = contact.name

        if let kana = name.normalizedFirstKana {
            if ("あ"..."ん").contains(kana) {
                grouped[kana, default: []].append(contact)
            } else if kana.first?.isLetter == true {
                let key = kana.uppercased()
                grouped[key, default: []].append(contact)
            } else {
                grouped["#", default: []].append(contact)
            }
        } else {
            grouped["#", default: []].append(contact)
        }
    }
    return grouped
}

extension String {
    /// 先頭文字（カタカナ→ひらがな変換付き）を取得
    var normalizedFirstKana: String? {
        guard let first = self.first else { return nil }
        var str = String(first)

        // カタカナ → ひらがな（Unicode差分で変換）
        if let scalar = str.unicodeScalars.first,
           scalar.value >= 0x30A1 && scalar.value <= 0x30F6 {
            let hira = UnicodeScalar(scalar.value - 0x60)!
            str = String(hira)
        }
        // 一覧に小文字を統一する
        let kanaMap: [Character: Character] = [
            "ぁ": "あ", "ぃ": "い", "ぅ": "う", "ぇ": "え", "ぉ": "お", "ゃ": "や", "ゅ": "ゆ", "ょ": "よ", "ゎ": "わ"
        ]
        if let mapped = kanaMap[str.first!] {
            str = String(mapped)
        }
        return str
    }
}

//// MARK: - PreferenceKey 用構造体
//struct SectionInfo: Equatable {
//    let key: String
//    let offset: CGFloat
//}
//
//struct SectionPreferenceKey: PreferenceKey {
//    static var defaultValue: [SectionInfo] = []
//    static func reduce(value: inout [SectionInfo], nextValue: () -> [SectionInfo]) {
//        value.append(contentsOf: nextValue())
//    }
//}

//enum SectionKey: String, CaseIterable {
//    case symbols = "#"
//    case japanese
//    case alphabet
//
//    static func from(character: Character) -> SectionKey {
//        if character.isLetter {
//            if ("あ"..."ん").contains(character) {
//                return .japanese
//            } else if ("A"..."Z").contains(character.uppercased()) {
//                return .alphabet
//            }
//        }
//        return .symbols
//    }
//}




struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(contacts: [
            Contact(name: "あいざわ"),
             Contact(name: "アイコ"),
             Contact(name: "あべ"),
            Contact(name: "アオキ"),
            Contact(name: "ぁきお"),

             // か行
             Contact(name: "かとう"),
             Contact(name: "カナエ"),
             Contact(name: "カズミ"),

             // さ行
             Contact(name: "ささき"),
             Contact(name: "サトル"),
             Contact(name: "しみず"),
             Contact(name: "シズカ"),

             // た行
             Contact(name: "たなか"),
             Contact(name: "タケシ"),

             // な行
             Contact(name: "なかむら"),
             Contact(name: "ナオコ"),

             // は行
             Contact(name: "はせがわ"),
             Contact(name: "ハルキ"),

             // ま行
             Contact(name: "まつもと"),
             Contact(name: "マサミ"),

             // や行
             Contact(name: "やまだ"),
             Contact(name: "ヤスオ"),

             // ら行
             Contact(name: "らいと"),
             Contact(name: "ライチ"),

             // わ行
             Contact(name: "わだ"),
             Contact(name: "ワカナ"),

             // ん
             Contact(name: "んどう"),

             // 英字
             Contact(name: "Alice"),
             Contact(name: "Bob"),
             Contact(name: "Charlie"),
             Contact(name: "David"),
             Contact(name: "Emma"),
             Contact(name: "Frank"),

             // 記号・数字・その他
             Contact(name: "*特別"),
             Contact(name: "123タロウ"),
             Contact(name: "!Exclamation"),
             Contact(name: "💡Idea"),
             Contact(name: "（カギカッコ）")
        ])
    }
}
