// lib/src/navigation/tab_navigator.dart

import '../core/native_bridge/native_bridge.dart';
import '../ui/primitives/view.dart';

class TabNavigator extends View {
  final List<Tab> tabs;
  int _currentIndex = 0;

  TabNavigator({required this.tabs, Map<String, dynamic> style = const {}})
      : super(children: tabs.map((tab) => tab.view).toList(), style: {'type': 'tabNavigator', ...style});

  void switchTab(int index) {
    if (index >= 0 && index < tabs.length) {
      _currentIndex = index;
      NativeBridge.render(toMap());
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'tabNavigator',
      'tabs': tabs.map((tab) => tab.toMap()).toList(),
      'currentIndex': _currentIndex,
      'style': style,
    };
  }
}

class Tab {
  final String label;
  final View view;
  final Map<String, dynamic> style;

  Tab({required this.label, required this.view, this.style = const {}});

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'view': view.toMap(),
      'style': style,
    };
  }
}