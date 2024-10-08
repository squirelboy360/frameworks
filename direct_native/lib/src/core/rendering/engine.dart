



import 'package:direct_native/src/core/native_bridge/native_bridge.dart';

class RenderingEngine {
  static void renderView(Map<String, dynamic> viewDescription) {
    MethodChannel.invokeMethod('renderView', viewDescription);
  }

  static void updateView(String viewId, Map<String, dynamic> updates) {
    MethodChannel.invokeMethod('updateView', {'viewId': viewId, 'updates': updates});
  }
}