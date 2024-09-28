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
    @State private var inputText: String = ""
    @State private var showDocumentPicker = false
    @State private var selectedFileName: String = "未选择文件"
    @State private var selectedFileURL: URL? = nil
    @State private var uploadedSounds: [String] = [] // 存储已上传声音的名称

    var body: some View {
        VStack(spacing: 10) { // 修改间距为10
            // 上传新声音标题
            Text("上传新声音")
                .font(.title) // 修改字体大小
                .fontWeight(.bold)
                .padding(.leading, 8) // 修改左边距为24px
                .padding(.trailing, 8) // 添加右边距为24px
                .frame(maxWidth: .infinity, alignment: .leading) // 靠左对齐

            // 选择声音框
            Button(action: {
                self.showDocumentPicker = true
            }) {
                HStack { // 使用 HStack 来排列图标和文字
                    Image(systemName: "square.and.arrow.up")
                        .font(.title) // 修改图标大小
                    Text("选择您的声音")
                        .font(.headline) // 修改字体大小
                        .foregroundColor(.blue)
                }
                .padding() // 添加内边距
                .frame(maxWidth: .infinity, minHeight: 50) // 设置最小高度
                .background(Color.purple.opacity(0.2))
                .cornerRadius(10)
                .padding(.top, 0) // 移除顶部间距
                .padding(.leading, 8) // 修改左边距为24px
                .padding(.trailing, 8) // 添加右边距为24px
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedFileName: $selectedFileName, selectedFileURL: $selectedFileURL)
            }

            // 上传按钮
            HStack { // 使用 HStack 使按钮右对齐
                Spacer() // 添加 Spacer 以推送按钮到右边
                Button(action: {
                    if let fileURL = selectedFileURL {
                        sendSelectedFile(fileURL: fileURL)
                    } else {
                        print("未选择文件")
                    }
                }) {
                    Text("上传")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(width: 120, height: 32) // 设置宽度和高度
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                .padding(.trailing, 8) // 添加右边距为8px
            }

            // 已上传声音列表
            HStack {
                Text("我的声音列表")
                    .font(.title2)
                    .foregroundColor(.blue)
                Spacer()
                Text("\(uploadedSounds.count)") // 显示上传数量
                    .padding(5)
                    .background(Color.purple.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()

            // 显示已上传声音名称
            List(uploadedSounds, id: \.self) { soundName in
                Text(soundName)
                    .background(Color.clear) // 移除灰色背景
            }

            Spacer()
        }
        .padding()
    }

    func sendSelectedFile(fileURL: URL) {
        print("准备发送文件: \(fileURL)")
        connectivity.sendFile(fileURL)
        print("文件已发送: \(fileURL)")

        // 更新已上传声音的名称列表
        uploadedSounds.append(selectedFileName)
        print("已上传声音列表更新: \(uploadedSounds)")

        // 清空选择的文件
        selectedFileName = "未选择文件"
        selectedFileURL = nil
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileName: String
    @Binding var selectedFileURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
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
            parent.selectedFileURL = url
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
