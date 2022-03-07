import 'package:flutter/widgets.dart';

Route getCurrentRoute(BuildContext context) {
  Route? currentRoute;
  Navigator.of(context).popUntil((route) { 
    currentRoute = route;
    return true;
  });
  assert(currentRoute != null);
  return currentRoute!;
}

void popCurrentRouteOfTypeIfAny<T extends Route>(BuildContext context) {
  Route currentRoute = getCurrentRoute(context);
  if (currentRoute is T)
    currentRoute.navigator!.pop();
}

mixin RemoveCompleterMixin<T> on Route<T> {
  void removeAndComplete(BuildContext context, [ T? result ]) {
    Navigator.removeRoute(context, this);
    assert(!isActive);
    didComplete(result);
  }
}

class OverlayRouteBuilder<T> extends OverlayRoute<T> with RemoveCompleterMixin {
  OverlayRouteBuilder({ required WidgetBuilder widgetBuilder }) :
    _widgetBuilder = widgetBuilder;

  OverlayRouteBuilder.fromWidget(Widget widget) :
    _widgetBuilder = ((_) => widget);

  OverlayRouteBuilder.empty() : 
    this.fromWidget(const SizedBox.shrink());

  WidgetBuilder _widgetBuilder;
  WidgetBuilder get widgetBuilder => _widgetBuilder;
  /// Causes the overlay widget of the route to rebuild if 
  /// [value] doesn't equal [widgetBuilder]. If only the 
  /// output of the builer has changed, call [markNeedsBuild].
  set widgetBuilder(WidgetBuilder value) {
    if (value == _widgetBuilder) return;
    _widgetBuilder = value;
    if (isActive)
      markNeedsBuild();
  }

  set widget(Widget value) {
    widgetBuilder = (_) => value;
  }

  void markNeedsBuild() {
    overlayEntries[0].markNeedsBuild();
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(builder: (context) => widgetBuilder(context));
  }
}