class Button {
  final String label;
  final Function onPressed;
  final Map<String, dynamic> style;

  Button({required this.label, required this.onPressed, this.style = const {}});

  Map<String, dynamic> toMap() {
    return {
      'type': 'button',
      'label': label,
      'style': style,
    };
  }
}