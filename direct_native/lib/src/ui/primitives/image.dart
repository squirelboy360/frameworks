class Image {
  final String source;
  final Map<String, dynamic> style;

  Image(this.source, {this.style = const {}});

  Map<String, dynamic> toMap() {
    return {
      'type': 'image',
      'source': source,
      'style': style,
    };
  }
}