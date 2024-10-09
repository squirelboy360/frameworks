import SwiftUI

@main
struct DirectNativeIOSApp: App {
    @StateObject private var bridge = DNBridge()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bridge)
        }
    }
}
