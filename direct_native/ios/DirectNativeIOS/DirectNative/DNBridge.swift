// ios/DirectNative/DNBridge.swift

import Foundation

@objc class DNBridge: NSObject {
    static let sharedInstance = DNBridge()
    private let renderer: DNRenderer
    
    private override init() {
        self.renderer = DNRenderer()
        super.init()
    }
    
    @objc func nativeRender(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            DispatchQueue.main.async {
                self.renderer.render(viewDescription: json)
            }
        }
    }
}