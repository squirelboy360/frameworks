// lib/src/navigation/stack_navigator.dart

import '../core/native_bridge/native_bridge.dart';
import '../ui/primitives/view.dart';

class StackNavigator extends View {
  final List<View> stack;

  StackNavigator({required this.stack, Map<String, dynamic> style = const {}})
      : super(children: stack, style: {'type': 'stackNavigator', ...style});

  void push(View view) {
    stack.add(view);
    NativeBridge.render(toMap());
  }

  void pop() {
    if (stack.length > 1) {
      stack.removeLast();
      NativeBridge.render(toMap());
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'stackNavigator',
      'children': stack.map((view) => view.toMap()).toList(),
      'style': style,
    };
  }
}
