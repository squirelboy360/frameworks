class View {
  final List<dynamic> children;
  final Map<String, dynamic> style;

  View({this.children = const [], this.style = const {}});

  Map<String, dynamic> toMap() {
    return {
      'type': 'view',
      'children': children.map((child) => child.toMap()).toList(),
      'style': style,
    };
  }
}