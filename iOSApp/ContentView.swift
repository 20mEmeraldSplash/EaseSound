//
//  ContentView.swift
//  iOSApp
//
//  Created by 汪猛男 on 9/22/24.
//

import SwiftUI
import WatchConnectivity
import UIKit

struct ContentView: View {
    @ObservedObject var connectivity = Connectivity()
    @State private var inputText: String = "" // 新增状态变量
    @State private var showDocumentPicker = false
    @State private var selectedFileName: String = "未选择文件"
    @State private var selectedFileURL: URL? = nil // 新增：保存选择的文件URL

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
            TextField("输入消息", text: $inputText) // 新增文本输入框
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 发送文字按钮
            Button("发送文字") {
                sendText()
            }
            .padding()

            // 选择文件按钮
            Button("选择文件") {
                self.showDocumentPicker = true
            }
            .padding()

            Text("选择的文件：\(selectedFileName)")
                .padding()

            // 发送文件按钮
            Button("发送文件") {
                if let fileURL = selectedFileURL {
                    sendSelectedFile(fileURL: fileURL)
                } else {
                    print("未选择文件")
                }
            }
            .padding()
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker, onDismiss: {
            print("Document Picker was dismissed")
        }) {
            DocumentPicker(selectedFileName: $selectedFileName, selectedFileURL: $selectedFileURL)
        }
    }

    // 发送文字的函数
    func sendText() {
        let fm = FileManager.default
        let sourceURL = URL.documentsDirectory.appendingPathComponent("saved_file")
        debugPrint(sourceURL.lastPathComponent)
        debugPrint(sourceURL)

        // 更新文件内容
        do {
            try inputText.write(to: sourceURL, atomically: true, encoding: .utf8)
            print("文件内容已更新: \(inputText)")
        } catch {
            print("写入文件失败: \(error)")
        }

        // 发送文件
        connectivity.sendFile(sourceURL)
        print("文件已发送: \(sourceURL)")

        // 清空输入框
        inputText = ""
        print("输入框已清空")
    }

    // 发送选择文件的函数
    func sendSelectedFile(fileURL: URL) {
        print("准备发送文件: \(fileURL)")
        connectivity.sendFile(fileURL)
        print("文件已发送: \(fileURL)")
    }
}

// 确保此扩展可供 ContentView 使用
extension URL {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// DocumentPicker结构体，用于选择文件
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileName: String
    @Binding var selectedFileURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true) // 只允许选择音频文件
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // 更新逻辑（如果需要）
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedFileName = url.lastPathComponent
            parent.selectedFileURL = url // 保存所选文件的 URL
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("文件选择被取消")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
