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
        }
    }

#if os(iOS)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    self.receivedText = "Watch app is installed!"
                }
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }
#else
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
        
    }
#endif


    func sendFile(_ url: URL) {
        let session = WCSession.default
        if session.activationState == .activated {
            session.transferFile(url, metadata: nil)
            print("文件传输请求已发送: \(url)") // 新增：打印传输请求的文件路径
        } else {
            print("会话未激活，无法发送文件") // 新增：打印会话状态
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let fm = FileManager.default
        let destURL = URL.documentsDirectory.appendingPathComponent("received_file.mp3") // 保存为 .mp3 文件
        do {
            if fm.fileExists(atPath: destURL.path) {
                try fm.removeItem(at: destURL)
                print("已删除旧文件: \(destURL)")
            }
            try fm.copyItem(at: file.fileURL, to: destURL)
            
            // 处理二进制文件，例如 MP3 文件
            let fileData = try Data(contentsOf: destURL)
            DispatchQueue.main.async {
                self.receivedText = "MP3 : \(fileData.count) bytes"
            }
            print("文件接收成功，大小为: \(fileData.count) 字节")
        } catch {
            DispatchQueue.main.async {
                self.receivedText = "File copy failed."
            }
            print("文件复制失败: \(error)")
        }
    }


}

