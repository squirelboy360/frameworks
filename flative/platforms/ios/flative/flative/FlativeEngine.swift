import Foundation
import Combine

class FlativeEngine: ObservableObject {
    static let shared = FlativeEngine()
    private var webSocket: URLSessionWebSocketTask?
    private let queue = DispatchQueue(label: "com.flative.engine", qos: .userInteractive)
    
    @Published private(set) var currentContent: [String: Any]?
    private var callbacks: [String: () -> Void] = [:]
    
    func connect(to url: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: url) else {
            completion(false)
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        receiveMessage()
        completion(true)
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    self?.handleBinaryMessage(data)
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        queue.async { [weak self] in
            DispatchQueue.main.async {
                self?.currentContent = json
            }
        }
    }
    
    private func handleBinaryMessage(_ data: Data) {
        // Handle binary messages if needed
    }
    
    func triggerCallback(id: String) {
        callbacks[id]?()
    }
    
    func registerCallback(_ id: String, callback: @escaping () -> Void) {
        callbacks[id] = callback
    }
    
    func send(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocket?.send(.string(string)) { error in
            if let error = error {
                print("Send error: \(error)")
            }
        }
    }
}
