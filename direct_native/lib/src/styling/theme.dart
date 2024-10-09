class Theme {
  final Map<String, dynamic> colors;
  final Map<String, dynamic> typography;

  Theme({required this.colors, required this.typography});

  static Theme defaultTheme = Theme(
    colors: {
      'primary': '#007AFF',
      'background': '#FFFFFF',
      'text': '#000000',
    },
    typography: {
      'body': {'fontSize': 16, 'fontWeight': 'normal'},
      'headline': {'fontSize': 24, 'fontWeight': 'bold'},
    },
  );
}