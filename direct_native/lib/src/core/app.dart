
import 'package:direct_native/src/core/native_bridge/native_bridge.dart';

import '../ui/primitives/view.dart';

class DNApp {
  final View rootView;

  DNApp({required this.rootView});

  void run() {
    MethodChannel.initialize();
    MethodChannel.invokeMethod('renderView', rootView.toMap());
  }
}
