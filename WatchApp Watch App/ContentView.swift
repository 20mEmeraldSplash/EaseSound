//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by 汪猛男 on 9/22/24.
//

import SwiftUI
import WatchConnectivity
import AVFoundation
import CoreMotion

struct ContentView: View {
    @StateObject var connectivity = Connectivity()
    @State private var audioPlayer: AVAudioPlayer? // Audio player
    private let motionManager = CMMotionManager() // For detecting motion
    @State private var coverImage: UIImage? = nil // To store the cover image

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
                    .foregroundColor(.purple)
            }
            .padding()
            .disabled(connectivity.receivedText.isEmpty) // Disable if no audio received

            Spacer()
        }
        .onAppear {
            startMonitoringMotion() // Start motion detection
            loadCoverImage() // Load the cover image if available
        }
        .onDisappear {
            stopMonitoringMotion() // Stop motion detection
        }
    }

    // Load the cover image (assuming it's received as part of the connectivity session)
    func loadCoverImage() {
        let imagePath = URL.documentsDirectory.appendingPathComponent("received_cover_image.png")
        if let imageData = try? Data(contentsOf: imagePath), let image = UIImage(data: imageData) {
            self.coverImage = image
        } else {
            print("Failed to load cover image")
        }
    }

    // Function to play audio
    func playAudio() {
        let fileURL = URL.documentsDirectory.appendingPathComponent("received_file.mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
            print("Audio started playing")
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let action = message["action"] as? String, action == "update" {
            // 处理更新逻辑，例如重新加载音频列表
            loadCoverImage() // 重新加载封面图像
            // 这里可以添加其他更新逻辑
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
