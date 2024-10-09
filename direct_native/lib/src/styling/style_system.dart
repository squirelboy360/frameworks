class StyleSystem {
  static Map<String, dynamic> combine(List<Map<String, dynamic>> styles) {
    return styles.reduce((value, element) => {...value, ...element});
  }
}