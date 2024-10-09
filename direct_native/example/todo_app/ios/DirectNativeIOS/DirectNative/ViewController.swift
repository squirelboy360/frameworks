import UIKit

class ViewController: UIViewController {
    private var bridge: DNBridge!

    override func viewDidLoad() {
        super.viewDidLoad()
        bridge = DNBridge()
        bridge.initialize()
    }
}
