import '../native_bridge/native_bridge.dart';

class RenderingEngine {
  static void render(Map<String, dynamic> uiDescription) {
    NativeBridge.render(uiDescription);
  }
}