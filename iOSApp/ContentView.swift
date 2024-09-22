//
//  ContentView.swift
//  iOSApp
//
//  Created by 汪猛男 on 9/22/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var connectivity = Connectivity()
    @State private var inputText: String = "" // 新增状态变量

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
            TextField("输入消息", text: $inputText) // 新增文本输入框
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("发送", action: sendFile) // 更新按钮文本
        }
        .padding()
    }

    func sendFile() {
        let fm = FileManager.default
        let sourceURL = URL.documentsDirectory.appendingPathComponent("saved_file")
        debugPrint(sourceURL.lastPathComponent)
        debugPrint(sourceURL)

        if !fm.fileExists(atPath: sourceURL.path) {
            try? inputText.write(to: sourceURL, atomically: true, encoding: .utf8) // 使用输入的文本
        }

        connectivity.sendFile(sourceURL)
    }
}

// Ensure this extension is accessible to the ContentView
extension URL {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

