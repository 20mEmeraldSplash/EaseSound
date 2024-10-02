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

            // 使用长方框包裹选择声音和添加封面图像的按钮
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 1) // 设置边框颜色和宽度
                .frame(height: 120) // 设置高度
                .overlay(
                    HStack(spacing: 0) { // 使用 HStack，设置按钮之间的间距
                        Button(action: {
                            self.showDocumentPicker = true
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                Text(selectedFileName)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                            .padding() // 内部 padding
                            .background(Color.clear) // 设置背景为透明
                        }
                        .sheet(isPresented: $showDocumentPicker) {
                            DocumentPicker(selectedFileName: $selectedFileName, selectedFileURL: $selectedFileURL)
                        }

                        Spacer() // 添加 Spacer 以创建空间

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
                                        .foregroundColor(.blue)
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
                    if let fileURL = selectedFileURL, selectedImage != nil {
                        sendSelectedFile(fileURL: fileURL)
                    } else {
                        print("未选择文件或图片")
                    }
                }) {
                    Text("上传")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(width: 120, height: 32)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                .padding(.trailing, 8)
                .disabled(selectedFileURL == nil || selectedImage == nil)
            }

            HStack {
                Text("我的声音列表")
                    .font(.title2)
                    .foregroundColor(.blue)
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

    func sendSelectedFile(fileURL: URL) {
        print("准备发送文件: \(fileURL)")
        connectivity.sendFile(fileURL)
        print("文件已发送: \(fileURL)")

        uploadedSounds.append(selectedFileName)
        print("已上传声音列表更新: \(uploadedSounds)")

        selectedFileName = "未选择文件"
        selectedFileURL = nil
        selectedImage = nil
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
        // Update logic (if needed)
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

// Image Picker to select images from the photo library
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
        // Update logic (if needed)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
