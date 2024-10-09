import SwiftUI

class DNBridge: ObservableObject {
    @Published var rootView: AnyView = AnyView(EmptyView())
    private let renderer = DNRenderer()
    
    func initialize() {
        // Perform any necessary initialization
        print("DNBridge initialized")
    }
    
    func nativeRender(_ uiDescription: String) {
        if let data = uiDescription.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            DispatchQueue.main.async {
                self.rootView = self.renderer.render(viewDescription: json)
            }
        }
    }
}
