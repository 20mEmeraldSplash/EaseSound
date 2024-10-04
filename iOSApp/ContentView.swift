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
    @State private var showDocumentPicker = false
    @State private var selectedFileName: String = "未选择文件"
    @State private var selectedFileURL: URL? = nil
    @State private var uploadedSounds: [String] = []
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("上传新声音")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 1)
                .frame(height: 120)
                .overlay(
                    HStack(spacing: 0) {
                        Button(action: {
                            self.showDocumentPicker = true
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                    .foregroundColor(.black)
                                Text(selectedFileName)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $showDocumentPicker) {
                            DocumentPicker(selectedFileName: $selectedFileName, selectedFileURL: $selectedFileURL)
                        }

                        Spacer()

                        Button(action: {
                            self.showImagePicker = true
                        }) {
                            VStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 104, height: 104)
                                        .clipped()
                                        .cornerRadius(10)
                                } else {
                                    Text("Add Cover Image")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .frame(width: 104, height: 104)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.trailing, 8)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $selectedImage)
                        }
                    }
                )
                .padding(8)

            HStack {
                Spacer()
                Button(action: {
                    if let fileURL = selectedFileURL, let image = selectedImage {
                        sendSelectedFiles(fileURL: fileURL, image: image)
                    } else {
                        print("未选择文件或图片")
                    }
                }) {
                    Text("上传")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 120, height: 32)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                }
                .padding(.trailing, 8)
                .disabled(selectedFileURL == nil || selectedImage == nil)
            }

            HStack {
                Text("我的声音列表")
                    .font(.title2)
                    .foregroundColor(.black)
                Spacer()
                Text("\(uploadedSounds.count)")
                    .padding(5)
                    .background(Color.purple.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()

            List(uploadedSounds, id: \.self) { soundName in
                Text(soundName)
                    .background(Color.clear)
            }

            Spacer()
        }
        .padding()
    }

    func sendSelectedFiles(fileURL: URL, image: UIImage) {
        print("准备发送文件: \(fileURL)")
        connectivity.sendFile(fileURL)  // 发送 MP3 文件

        // 压缩图片并保存
        if let imageData = image.jpegData(compressionQuality: 0.1) { // 压缩到50%质量
            let imageURL = saveImageToFile(data: imageData)
            print("准备发送图片文件: \(imageURL)") // 添加调试信息
            connectivity.sendFile(imageURL)  // 发送图片文件
        } else {
            print("压缩图片失败")
        }

        // 新增代码：发送更新通知到手表
        let updateMessage = ["action": "update", "fileName": selectedFileName]
        connectivity.sendMessage(updateMessage)  // 发送更新消息

        uploadedSounds.append(selectedFileName)
        print("已上传声音列表更新: \(uploadedSounds)")

        selectedFileName = "未选择文件"
        selectedFileURL = nil
        selectedImage = nil
    }

    func saveImageToFile(data: Data) -> URL {
        let fileURL = URL.documentsDirectory.appendingPathComponent("temp_image.png")
        do {
            try data.write(to: fileURL)
            print("图片保存成功: \(fileURL)")
        } catch {
            print("保存图片失败: \(error)")
        }
        return fileURL
    }
}

// 恢复的 DocumentPicker 组件
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileName: String
    @Binding var selectedFileURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // 无需更新
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

// 恢复的 ImagePicker 组件
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 无需更新
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
