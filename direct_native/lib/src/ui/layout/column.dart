import '../primitives/view.dart';

class Column extends View {
  Column({List<dynamic> children = const [], Map<String, dynamic> style = const {}})
      : super(children: children, style: {'flexDirection': 'column', ...style});
}