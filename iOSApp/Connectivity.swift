import UIKit
import Foundation
import WatchConnectivity

class Connectivity: NSObject, ObservableObject, WCSessionDelegate {

    @Published var receivedText: String = ""

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession 已初始化并激活")
        } else {
            print("WCSession 不支持")
        }
    }

#if os(iOS)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    self.receivedText = "Watch app is installed!"
                    print("手表应用已安装")
                }
            } else {
                print("WCSession 未激活，激活状态为: \(activationState.rawValue)")
            }
            if let error = error {
                print("激活时出现错误: \(error.localizedDescription)")
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession 已变为非活动状态")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession 已停用")
    }
#else
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watchOS WCSession 激活完成，状态为: \(activationState.rawValue)")
        if let error = error {
            print("watchOS 激活时出现错误: \(error.localizedDescription)")
        }
    }
#endif

    // 发送文件，带有详细的输出信息
    func sendFile(_ url: URL) {
        let session = WCSession.default
        if session.activationState == .activated {
            session.transferFile(url, metadata: ["fileType": url.pathExtension])
            print("文件传输请求已发送: \(url.lastPathComponent)，文件类型为: \(url.pathExtension)")
        } else {
            print("会话未激活，无法发送文件")
        }
    }

    func sendMessage(_ message: [String: Any]) {
        let session = WCSession.default
        if session.activationState == .activated {
            session.sendMessage(message, replyHandler: nil) { error in
                print("发送消息失败: \(error.localizedDescription)")
            }
        } else {
            print("会话未激活，无法发送消息")
        }
    }

    // 接收文件，带有详细的输出信息
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("开始接收文件: \(file.fileURL.lastPathComponent)")

        let fm = FileManager.default
        
        guard let fileType = file.metadata?["fileType"] as? String else {
            print("接收到文件但没有文件类型元数据")
            return
        }
        
        let destURL: URL
        if fileType == "mp3" {
            destURL = URL.documentsDirectory.appendingPathComponent("received_file.mp3")
            print("准备将文件保存为 MP3: \(destURL)")
        } else if fileType == "png" || fileType == "jpg" {
            destURL = URL.documentsDirectory.appendingPathComponent("received_cover_image.\(fileType)")
            print("准备将文件保存为图片: \(destURL)")
        } else {
            print("未知文件类型: \(fileType)")
            return
        }

        do {
            if fm.fileExists(atPath: destURL.path) {
                try fm.removeItem(at: destURL)
                print("已删除旧文件: \(destURL)")
            }
            try fm.copyItem(at: file.fileURL, to: destURL)
            print("文件成功复制到目标路径: \(destURL)")

            if fileType == "mp3" {
                let fileData = try Data(contentsOf: destURL)
                DispatchQueue.main.async {
                    self.receivedText = "MP3 : \(fileData.count) bytes"
                }
                print("MP3 文件接收成功，大小为: \(fileData.count) 字节")
            } else if fileType == "png" || fileType == "jpg" {
                DispatchQueue.main.async {
                    self.receivedText = "图片接收成功"
                }
                print("图片文件接收成功: \(destURL)")
            }

        } catch {
            DispatchQueue.main.async {
                self.receivedText = "File copy failed."
            }
            print("文件复制失败: \(error)")
        }
    }

    // 新增：接收消息并处理更新
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let action = message["action"] as? String, action == "update" {
            print("收到更新消息，重新加载封面图像")
            DispatchQueue.main.async {
                self.loadCoverImage() // 调用加载封面图像的方法
            }
        }
    }

    // 加载封面图像的方法
    func loadCoverImage() {
        let imagePath = URL.documentsDirectory.appendingPathComponent("received_cover_image.png")
        print("尝试加载封面图像: \(imagePath)")
        if let imageData = try? Data(contentsOf: imagePath), let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                // 假设你有一个方法来更新手表端的 UI
                // 这里需要调用手表端的更新方法
                // 例如：self.updateCoverImage(image)
                print("成功加载封面图像")
            }
        } else {
            print("加载封面图像失败")
        }
    }
}