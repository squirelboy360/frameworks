import 'native_bridge/native_bridge.dart';
import '../ui/primitives/view.dart';

class DNApp {
  final View rootView;

  DNApp({required this.rootView});

  void run() {
    NativeBridge.initialize();
    NativeBridge.render(rootView.toMap());
  }
}