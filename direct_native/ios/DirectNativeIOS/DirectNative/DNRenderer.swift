import UIKit

class DNRenderer {
    private weak var viewController: UIViewController?
    private var rootView: UIView?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func initialize() {
        rootView = UIView(frame: viewController?.view.bounds ?? .zero)
        rootView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController?.view.addSubview(rootView!)
    }
    
    func render(uiDescription: String) {
        guard let data = uiDescription.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }
        
        rootView?.subviews.forEach { $0.removeFromSuperview() }
        addViewToParent(viewDescription: json, parent: rootView!)
    }
    
    private func addViewToParent(viewDescription: [String: Any], parent: UIView) {
        guard let type = viewDescription["type"] as? String else { return }
        
        switch type {
        case "view":
            renderView(viewDescription, parent: parent)
        case "text":
            renderText(viewDescription, parent: parent)
        case "button":
            renderButton(viewDescription, parent: parent)
        case "image":
            renderImage(viewDescription, parent: parent)
        default:
            break
        }
    }
    
    private func renderView(_ description: [String: Any], parent: UIView) {
        let view = UIView()
        if let children = description["children"] as? [[String: Any]] {
            for child in children {
                addViewToParent(viewDescription: child, parent: view)
            }
        }
        applyStyle(to: view, style: description["style"] as? [String: Any] ?? [:])
        parent.addSubview(view)
    }
    
    private func renderText(_ description: [String: Any], parent: UIView) {
        let label = UILabel()
        label.text = description["content"] as? String
        applyStyle(to: label, style: description["style"] as? [String: Any] ?? [:])
        parent.addSubview(label)
    }
    
    private func renderButton(_ description: [String: Any], parent: UIView) {
        let button = UIButton(type: .system)
        button.setTitle(description["label"] as? String, for: .normal)
        applyStyle(to: button, style: description["style"] as? [String: Any] ?? [:])
        parent.addSubview(button)
    }
    
    private func renderImage(_ description: [String: Any], parent: UIView) {
        let imageView = UIImageView()
        // TODO: Implement image loading
        applyStyle(to: imageView, style: description["style"] as? [String: Any] ?? [:])
        parent.addSubview(imageView)
    }
    
    private func applyStyle(to view: UIView, style: [String: Any]) {
        if let backgroundColor = style["backgroundColor"] as? String {
            view.backgroundColor = UIColor(hexString: backgroundColor)
        }
        if let color = style["color"] as? String, let label = view as? UILabel {
            label.textColor = UIColor(hexString: color)
        }
        if let fontSize = style["fontSize"] as? CGFloat, let label = view as? UILabel {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        if let padding = style["padding"] as? CGFloat {
            view.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
        // Add more style properties as needed
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
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
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}