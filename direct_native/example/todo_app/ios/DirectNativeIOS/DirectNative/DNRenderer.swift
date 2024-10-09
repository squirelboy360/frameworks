import SwiftUI

class DNRenderer {
    func render(viewDescription: [String: Any]) -> AnyView {
        return renderView(viewDescription)
    }
    
    private func renderView(_ description: [String: Any]) -> AnyView {
        let type = description["type"] as? String ?? ""
        switch type {
        case "view":
            return AnyView(renderViewGroup(description))
        case "text":
            return AnyView(renderText(description))
        case "button":
            return AnyView(renderButton(description))
        default:
            return AnyView(EmptyView())
        }
    }
    
    private func renderViewGroup(_ description: [String: Any]) -> some View {
        let children = description["children"] as? [[String: Any]] ?? []
        return VStack {
            ForEach(0..<children.count, id: \.self) { index in
                self.renderView(children[index])
            }
        }
    }
    
    private func renderText(_ description: [String: Any]) -> some View {
        let content = description["content"] as? String ?? ""
        let style = description["style"] as? [String: Any] ?? [:]
        return Text(content)
            .font(.system(size: CGFloat(style["fontSize"] as? Int ?? 14)))
            .foregroundColor(Color(hex: style["color"] as? String ?? "#000000"))
    }
    
    private func renderButton(_ description: [String: Any]) -> some View {
        let label = description["label"] as? String ?? ""
        let style = description["style"] as? [String: Any] ?? [:]
        return Button(action: {
            // Handle button action
            print("Button tapped: \(label)")
        }) {
            Text(label)
                .foregroundColor(Color(hex: style["color"] as? String ?? "#FFFFFF"))
                .padding()
                .background(Color(hex: style["backgroundColor"] as? String ?? "#0000FF"))
                .cornerRadius(8)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
