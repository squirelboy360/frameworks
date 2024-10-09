import '../primitives/view.dart';

class Row extends View {
  Row({List<dynamic> children = const [], Map<String, dynamic> style = const {}})
      : super(children: children, style: {'flexDirection': 'row', ...style});
}