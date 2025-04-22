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
//            VStack(alignment: .leading, spacing: 12) {
                ForEach(sortedKeys, id: \.self) { key in
                    sectionView(key: key, contacts: grouped[key] ?? [])
                        .background(GeometryReader { geo in
                            Color
                                .clear
                                .onAppear {
                                    sectionOffsets[key] = geo.frame(in: .named("scroll")).minY
                                }
                                .onChange(of: geo.frame(in: .named("scroll")).minY) { value in
                                    print("key:\(key),value\(value)")
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
                BalloonView(word: key)
                    .offset(x: -10, y: scrollOffset / 1.8)
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
            "ぁ": "あ", "ぃ": "い", "ぅ": "う", "ぇ": "え", "ぉ": "お", "ゕ": "か", "ゖ": "け", "ゃ": "や", "ゅ": "ゆ", "ょ": "よ", "ゎ": "わ"
        ]
        if let mapped = kanaMap[str.first!] {
            str = String(mapped)
        }
        return str
    }
}

struct BalloonView: View {
    var word: String
    var body: some View {
        BalloonShape()
            .fill(Color.red.opacity(0.75))
            .overlay(
                Text(word)
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8),
                alignment: .center
            )
            .frame(width: 100, height: 100)
    }
}

struct BalloonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 10
        let tailWidth: CGFloat = 10
        let tailHeight: CGFloat = 10
        // 本体の四角形（右下だけ欠ける）
        path.addRoundedRect(in: CGRect(x: rect.minX,
                                       y: rect.minY,
                                       width: rect.width - tailWidth,
                                       height: rect.height),
                            cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        // 右側に三角のしっぽ
        path.move(to: CGPoint(x: rect.maxX - tailWidth, y: rect.midY - tailHeight / 2))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - tailWidth, y: rect.midY + tailHeight / 2))
        path.closeSubpath()

        return path
    }
}


struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(contacts: [
            Contact(name: "あいざわ"), Contact(name: "アイコ"), Contact(name: "あべ"),
            Contact(name: "アオキ"), Contact(name: "ぁきお"),
            Contact(name: "かとう"), Contact(name: "カナエ"), Contact(name: "カズミ"),
            Contact(name: "ささき"), Contact(name: "サトル"), Contact(name: "しみず"), Contact(name: "シズカ"),
            Contact(name: "たなか"), Contact(name: "タケシ"),
            Contact(name: "なかむら"), Contact(name: "ナオコ"),
            Contact(name: "はせがわ"), Contact(name: "ハルキ"),
            Contact(name: "まつもと"), Contact(name: "マサミ"),
            Contact(name: "やまだ"), Contact(name: "ヤスオ"),
            Contact(name: "らいと"), Contact(name: "ライチ"),
            Contact(name: "わだ"), Contact(name: "ワカナ"),
            Contact(name: "んどう"),
            Contact(name: "Alice"), Contact(name: "Bob"), Contact(name: "Charlie"), Contact(name: "David"), Contact(name: "Emma"), Contact(name: "Frank"),
            Contact(name: "*特別"), Contact(name: "123タロウ"), Contact(name: "!Exclamation"),
            Contact(name: "💡Idea"), Contact(name: "（カギカッコ）")
        ])
    }
}
