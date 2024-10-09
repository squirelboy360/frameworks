import '../primitives/view.dart';

class Modal extends View {
  final View content;
  final bool isVisible;
  final Function? onDismiss;

  Modal({
    required this.content,
    this.isVisible = false,
    this.onDismiss,
    Map<String, dynamic> style = const {},
  }) : super(
          children: [content],
          style: {
            'position': 'absolute',
            'top': 0,
            'left': 0,
            'right': 0,
            'bottom': 0,
            'backgroundColor': 'rgba(0,0,0,0.5)',
            'justifyContent': 'center',
            'alignItems': 'center',
            'display': isVisible ? 'flex' : 'none',
            ...style,
          },
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'modal',
      'content': content.toMap(),
      'isVisible': isVisible,
      'style': style,
    };
  }
}