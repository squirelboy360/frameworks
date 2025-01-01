import SwiftUI

struct FlativeRenderer: View {
    let content: [String: Any]
    
    var body: some View {
        renderWidget(content)
    }
    
    @ViewBuilder
    private func renderWidget(_ data: [String: Any]) -> some View {
        switch data["type"] as? String {
        case "text":
            if let text = data["text"] as? String {
                Text(text)
                    .modifier(TextStyleModifier(data))
            }
        case "button":
            if let text = data["text"] as? String {
                Button(text) {
                    FlativeEngine.shared.triggerCallback(id: data["callbackId"] as? String ?? "")
                }
                .modifier(ButtonStyleModifier(data))
            }
        case "container":
            ContainerView(data: data)
        case "scaffold":
            ScaffoldView(data: data)
        default:
            Text("Unknown widget")
        }
    }
}

struct TextStyleModifier: ViewModifier {
    let data: [String: Any]
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: data["fontSize"] as? CGFloat ?? 14))
            .fontWeight(weightFromString(data["fontWeight"] as? String))
    }
    
    private func weightFromString(_ weight: String?) -> Font.Weight {
        switch weight {
        case "bold": return .bold
        case "light": return .light
        default: return .regular
        }
    }
}

struct ButtonStyleModifier: ViewModifier {
    let data: [String: Any]
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .disabled(!(data["enabled"] as? Bool ?? true))
    }
}

struct ContainerView: View {
    let data: [String: Any]
    
    var body: some View {
        if let child = data["child"] as? [String: Any] {
            FlativeRenderer(content: child)
                .frame(
                    width: data["width"] as? CGFloat,
                    height: data["height"] as? CGFloat
                )
                .padding(paddingFromData(data["padding"] as? [String: Any]))
        }
    }
    
    private func paddingFromData(_ data: [String: Any]?) -> EdgeInsets {
        guard let padding = data else { return EdgeInsets() }
        return EdgeInsets(
            top: padding["top"] as? CGFloat ?? 0,
            leading: padding["left"] as? CGFloat ?? 0,
            bottom: padding["bottom"] as? CGFloat ?? 0,
            trailing: padding["right"] as? CGFloat ?? 0
        )
    }
}

struct ScaffoldView: View {
    let data: [String: Any]
    
    var body: some View {
        NavigationView {
            if let body = data["body"] as? [String: Any] {
                FlativeRenderer(content: body)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        if let appBar = data["appBar"] as? [String: Any],
                           let title = appBar["title"] as? String {
                            ToolbarItem(placement: .principal) {
                                Text(title)
                            }
                        }
                    }
            }
        }
    }
}
