//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by 汪猛男 on 9/22/24.
//
import UIKit
import SwiftUI
import WatchConnectivity
import AVFoundation
import CoreMotion


struct ContentView: View {
    @StateObject var connectivity = Connectivity()
    @State private var audioPlayer: AVAudioPlayer? // Audio player
    private let motionManager = CMMotionManager() // For detecting motion
    @State private var coverImage: UIImage? = nil // To store the cover image
    @State private var isAudioAvailable = false // To check if audio is available

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let action = message["action"] as? String, action == "update" {
            print("---------重新加载")
            DispatchQueue.main.async {
                loadCoverImage() // 重新加载封面图像
                checkAudioAvailability() // 检查音频是否可用
                self.coverImage = self.coverImage // 触发视图更新
            }
        }
    }

    func loadCoverImage() {
        DispatchQueue.main.async {
            let imagePath = URL.documentsDirectory.appendingPathComponent("received_cover_image.png")
            print("*尝试加载封面图像: \(imagePath)") // 添加调试信息
            if let imageData = try? Data(contentsOf: imagePath), let image = UIImage(data: imageData) {
                self.coverImage = image // 更新封面图像
                print("*成功加载封面图像") // 添加调试信息
            } else {
                print("*加载封面图像失败") // 添加调试信息
            }
        }
    }

    func checkAudioAvailability() {
        let fileURL = URL.documentsDirectory.appendingPathComponent("received_file.mp3")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            isAudioAvailable = true
        } else {
            isAudioAvailable = false
        }
    }

    var body: some View {
        VStack {
            // Display the cover image in a circle if available
            if let coverImage = coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle()) // Make the image circular
                    .frame(width: 100, height: 100) // Adjust the size as needed
                    .padding()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .overlay(Text("No Cover").foregroundColor(.white))
                    .padding()
            }

            // Play button below the cover image
            Button(action: {
                playAudio()
            }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50) // Adjust the play button size
                    .foregroundColor(isAudioAvailable ? .white : .gray) 
            }
            .background(Color.clear)
            .buttonStyle(PlainButtonStyle()) // Remove default button style
            .disabled(!isAudioAvailable) // Disable if no audio available

            Spacer()
        }
        .onAppear {
            startMonitoringMotion() // Start motion detection
            loadCoverImage() // Load the cover image if available
            checkAudioAvailability() // Check if audio is available
        }
        .onDisappear {
            stopMonitoringMotion() // Stop motion detection
        }
    }

    


    // Function to play audio
    func playAudio() {
        loadCoverImage() //可能要删掉
        let fileURL = URL.documentsDirectory.appendingPathComponent("received_file.mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
            print("Audio started playing")
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    

    // Start monitoring motion for wrist flick
    private func startMonitoringMotion() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let data = data else { return }
                // Detect strong wrist flick motion
                if abs(data.acceleration.x) > 1.5 || abs(data.acceleration.y) > 1.5 {
                    playAudio() // Play audio when flicked
                }
            }
        }
    }

    // Stop motion monitoring
    private func stopMonitoringMotion() {
        motionManager.stopAccelerometerUpdates()
    }
}

#Preview {
    ContentView()
}
