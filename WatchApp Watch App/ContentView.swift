//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by 汪猛男 on 9/22/24.
//

import SwiftUI
import WatchConnectivity
import AVFoundation // 导入 AVFoundation 以支持音频播放
import CoreMotion // 导入 CoreMotion 以监测运动

struct ContentView: View {
    @StateObject var connectivity = Connectivity()
    @State private var audioPlayer: AVAudioPlayer? // 新增音频播放器
    private let motionManager = CMMotionManager() // 新增：运动管理器

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
                .padding()
            Text("😊") // 新增提示语
            
            // 播放按钮
            Button("播放音频") {
                playAudio() // 调用播放音频的函数
            }
            .padding()
            .disabled(connectivity.receivedText.isEmpty) // 如果没有接收到音频，则禁用按钮
        }
        .onAppear {
            startMonitoringMotion() // 启动运动监测
        }
        .onDisappear {
            stopMonitoringMotion() // 停止运动监测
        }
    }

    // 播放音频的函数
    func playAudio() {
        let fileURL = URL.documentsDirectory.appendingPathComponent("received_file.mp3") // 确保文件路径正确
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
            print("开始播放音频")
        } catch {
            print("播放音频失败: \(error)")
        }
    }

    // 启动运动监测
    private func startMonitoringMotion() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let data = data else { return }
                // 检测挥动手臂的条件
                if abs(data.acceleration.x) > 1.5 || abs(data.acceleration.y) > 1.5 {
                    playAudio() // 播放音频
                }
            }
        }
    }

    // 停止运动监测
    private func stopMonitoringMotion() {
        motionManager.stopAccelerometerUpdates()
    }
}

#Preview {
    ContentView()
}
