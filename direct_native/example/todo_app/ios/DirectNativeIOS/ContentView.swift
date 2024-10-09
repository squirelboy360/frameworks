import SwiftUI

struct ContentView: View {
    @StateObject private var bridge = DNBridge()
    
    let uiDescription: String = """
    {
        "type": "view",
        "children": [
            {
                "type": "text",
                "content": "Welcome to Direct Native!",
                "style": {
                    "fontSize": 24,
                    "color": "#000000"
                }
            },
            {
                "type": "button",
                "label": "Click me",
                "style": {
                    "backgroundColor": "#0000FF",
                    "color": "#FFFFFF"
                }
            }
        ],
        "style": {
            "padding": 16,
            "backgroundColor": "#FFFFFF"
        }
    }
    """
    
    var body: some View {
        bridge.rootView
            .onAppear {
                bridge.initialize()
                bridge.nativeRender(uiDescription)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
