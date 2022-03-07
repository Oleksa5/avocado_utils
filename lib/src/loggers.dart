// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'flutter_debug_print.dart';
import 'string_utilities.dart';

void printAction(String string) {
  print(actionStyleEsc + string + resetEsc);
}

mixin Printer {
  void debugPrint({int indent = 0}); 
}

mixin WidgetDebug on Widget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString(minLevel: minLevel) + '#${shortHash(hashCode)}:';
  }
}

mixin StateLogger<T extends StatefulWidget> on State<T> 
{
  Type? get parentWidgetType => null;

  @override
  void initState() {
    super.initState();
    print(dimTextEsc + toString() + actionDimStyleEsc + ' is inserted into the tree' + resetEsc);
    _printAncestors(indent: 2);
    print('');
  }

  void logOnBuild() {
    print(dimTextEsc + toString() + actionDimStyleEsc + ' is on build' + resetEsc);
    _printAncestors(indent: 2);
    print('');
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(dimTextEsc + toString() + actionDimStyleEsc + ' has updated widget: ' + resetEsc);
    print(indentString(2) + dimTextEsc + 'old widget:');
    print(indentString(4) + oldWidget.toString());
    print(indentString(2) + dimTextEsc + 'new widget:');
    print(indentString(4) + widget.toString());
    _printAncestors(indent: 2);
    print('');
  }

  @override
  void deactivate() {
    super.deactivate();
    print(dimTextEsc + toString() + actionDimStyleEsc + ' is deactivated' + resetEsc);
    _printAncestors(indent: 2);
    print('');
  }

  @override
  void dispose() {
    super.dispose();
    print(dimTextEsc + toString() + actionDimStyleEsc + ' is disposed' + resetEsc);
    print('');
  }

  void _printAncestors({int indent = 0}) {
    print(indentString(indent) + dimTextEsc + 'this' 
      + ancestorsString(context, highlightedType: parentWidgetType, highlightedEsc: dimGreenTextEsc, resetEsc: dimTextEsc) + resetEsc);
  }
}

String elementToString(BuildContext element) {
  String stateString = element is StatefulElement ? element.state.toString() : '';
  return element.widget.toString() + ' ' + stateString + ' ' + 'Element#${element.hashCode}'+ ' ' + ancestorsString(element);
}

String stateToString(State state) {
  return elementToString(state.context);
}

void printElement(BuildContext element, {int indent = 0}) {
  print(indentString(indent) + elementToString(element));
}

void printState(State state, {int indent = 0}) {
  print(indentString(indent) + stateToString(state));
}

String ancestorsString(
  BuildContext context, {
  Type? highlightedType, 
  String highlightedEsc = actionStyleEsc, 
  String resetEsc = resetEsc
}) {
  final buffer = StringBuffer();
  context.visitAncestorElements(
    (element) { 
      if (highlightedType != null && element.widget.runtimeType == highlightedType)
        buffer.write(' ← ' + dimGreenTextEsc + element.toStringShort() + '#${element.hashCode}' + resetEsc);
      else 
        buffer.write(' ← ' + element.toStringShort() + '#${element.hashCode}');
      return true;
    }
  );
  return buffer.toString();
}
