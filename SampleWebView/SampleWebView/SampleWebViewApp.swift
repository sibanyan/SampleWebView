//
//  SampleWebViewApp.swift
//  SampleWebView
//
//  Created by shibata on 2025/04/06.
//

import SwiftUI

@main
struct SampleWebViewApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            ListView(contacts: contacts)
        }
    }
}
let contacts: [Contact] = [
    Contact(name: "あいざわ"),
    Contact(name: "アイコ"),
    Contact(name: "あべ"),
    Contact(name: "アオキ"),
    Contact(name: "ぁきお"),
    Contact(name: "ぃきみ"),
    Contact(name: "ゃつみ"),
    Contact(name: "がっつ"),
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
    ]
