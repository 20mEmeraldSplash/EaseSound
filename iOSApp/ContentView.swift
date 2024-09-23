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

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
            TextField("输入消息", text: $inputText) // 新增文本输入框
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("发送", action: sendFile) // 更新按钮文本
            Button("选择文件") {
                self.showDocumentPicker = true
            }
            Text("选择的文件：\(selectedFileName)")
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker, onDismiss: {
            print("Document Picker was dismissed")
        }) {
            DocumentPicker(selectedFileName: $selectedFileName)
        }
    }

    func sendFile() {
        let fm = FileManager.default
        let sourceURL = URL.documentsDirectory.appendingPathComponent("saved_file")
        debugPrint(sourceURL.lastPathComponent)
        debugPrint(sourceURL)

        // 更新文件内容
        do {
            try inputText.write(to: sourceURL, atomically: true, encoding: .utf8) // 使用输入的文本
            print("文件内容已更新: \(inputText)") // 新增：打印更新的内容
        } catch {
            print("写入文件失败: \(error)") // 新增：打印错误信息
        }

        // 发送文件
        connectivity.sendFile(sourceURL)
        print("文件已发送: \(sourceURL)") // 新增：打印发送的文件路径

        // 清空输入框
        inputText = "" // 新增：清空输入框
        print("输入框已清空") // 新增：打印清空状态
    }
}

// Ensure this extension is accessible to the ContentView
extension URL {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileName: String

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
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
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("document picker was cancelled")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

