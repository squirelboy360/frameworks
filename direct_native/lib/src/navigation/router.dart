import '../ui/primitives/view.dart';

class Route {
  final String name;
  final View Function(Map<String, dynamic>) builder;

  Route({required this.name, required this.builder});
}

class Router {
  final Map<String, Route> _routes = {};

  void addRoute(Route route) {
    _routes[route.name] = route;
  }

  View? navigate(String routeName, [Map<String, dynamic> params = const {}]) {
    final route = _routes[routeName];
    if (route != null) {
      return route.builder(params);
    }
    return null;
  }
}