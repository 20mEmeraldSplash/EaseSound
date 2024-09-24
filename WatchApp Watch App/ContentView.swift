//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by 汪猛男 on 9/22/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject var connectivity = Connectivity()

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
                .padding()
            Text("😊") // 新增提示语
        }
    }
}


#Preview {
    ContentView()
}
