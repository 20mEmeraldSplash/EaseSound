//
//  ContentView.swift
//  iOSApp
//
//  Created by 汪猛男 on 9/22/24.
//

import SwiftUI
import WatchConnectivity

import SwiftUI

struct ContentView: View {
    @ObservedObject var connectivity = Connectivity()

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
            Button("Message", action: sendFile)
        }
        .padding()
    }

    func sendFile() {
        let fm = FileManager.default
        let sourceURL = URL.documentsDirectory.appendingPathComponent("saved_file")
        debugPrint(sourceURL.lastPathComponent)
        debugPrint(sourceURL)

        if !fm.fileExists(atPath: sourceURL.path) {
            try? "Hello, from a phone file".write(to: sourceURL, atomically: true, encoding: .utf8)
        }

        connectivity.sendFile(sourceURL)
    }
}

// Ensure this extension is accessible to the ContentView
extension URL {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

