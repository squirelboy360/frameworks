class Text {
  final String content;
  final Map<String, dynamic> style;

  Text(this.content, {this.style = const {}});

  Map<String, dynamic> toMap() {
    return {
      'type': 'text',
      'content': content,
      'style': style,
    };
  }
}
