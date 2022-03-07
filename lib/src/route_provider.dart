import 'package:flutter/widgets.dart';

class RouteProvider<RouteT extends Route> {
  RouteProvider({ required this.routeBuilder }) {
    updateRoute();
  }
  final RouteT Function() routeBuilder;
  late RouteT route;
  void updateRoute() {
    route = routeBuilder();
    route.popped.then((_) => updateRoute());
  }
}