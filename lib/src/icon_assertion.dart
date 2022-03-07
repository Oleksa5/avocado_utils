import 'dart:math' show min;

import 'package:flutter/widgets.dart';

class IconAssertion extends StatelessWidget {
  const IconAssertion(
    Widget icon, { 
    Key? key,
    this.tolerance = 0
  }) :
    assert(icon is Icon),
    icon = icon as Icon,
    super(key: key);

  final Icon icon;
  final double tolerance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = icon.size ?? IconTheme.of(context).size!;
        assert(() {
          double availableSize = min(constraints.maxWidth, constraints.maxHeight) + tolerance;
          assert(size <= availableSize, 'The icon\'s overflow is ${size - availableSize}.');
          return true;
        }());
        return icon;
      } 
    );
  }
}