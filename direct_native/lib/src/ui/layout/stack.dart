import '../primitives/view.dart';

class Stack extends View {
  Stack({List<dynamic> children = const [], Map<String, dynamic> style = const {}})
      : super(children: children, style: {'position': 'relative', ...style});
}