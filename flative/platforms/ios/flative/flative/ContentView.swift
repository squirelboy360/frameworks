//
//  ContentView.swift
//  flative
//
//  Created by Tahiru Agbanwa on 12/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var serverUrl = ""
    @State private var isConnected = false
    
    var body: some View {
        if isConnected {
            FlativeDome()
        } else {
            ConnectView(serverUrl: $serverUrl, isConnected: $isConnected)
        }
    }
}

struct ConnectView: View {
    @Binding var serverUrl: String
    @Binding var isConnected: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Connect to Flative")
                .font(.largeTitle)
            
            TextField("Server URL", text: $serverUrl)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Connect") {
//                FlativeEngine.shared.connect(to: serverUrl) { success in
//                    if success {
//                        isConnected = true
//                    }
//                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(serverUrl.isEmpty)
        }
        .padding()
    }
}

struct FlativeDome: View {
//    @StateObject private var engine = FlativeEngine.shared
    
    var body: some View {
        
        //        ZStack {
        //            if let content = engine.currentContent {
        //                FlativeRenderer(content: content)
        //            } else {
        //                Text("Waiting for Flative content...")
        //            }
        //        }
        
        Text("Hello World!")
    
    }
}

#Preview {
    ContentView()
}
