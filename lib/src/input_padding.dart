import 'dart:math' show max;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class InputPadding extends SingleChildRenderObjectWidget {
  const InputPadding({
    Key? key,
    Widget? child,
    required this.minSize,
  }) : super(key: key, child: child);

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderInputPadding renderObject) {
    renderObject.minSize = minSize;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, [RenderBox? child]) : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value)
      return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null)
      return max(child!.getMinIntrinsicWidth(height), minSize.width);
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null)
      return max(child!.getMinIntrinsicHeight(width), minSize.height);
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null)
      return max(child!.getMaxIntrinsicWidth(height), minSize.width);
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null)
      return max(child!.getMaxIntrinsicHeight(width), minSize.height);
    return 0.0;
  }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}) {
    if (child != null) {
      final Size childSize = layoutChild(child!, constraints);
      final double height = max(childSize.width, minSize.width);
      final double width = max(childSize.height, minSize.height);
      return constraints.constrain(Size(height, width));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Alignment.center.alongOffset(size - child!.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, { required Offset position }) {
    if (super.hitTest(result, position: position)) {
      return true;
    } else if (size.contains(position)) {
      final Offset center = child!.size.center(Offset.zero);
      return result.addWithRawTransform(
        transform: MatrixUtils.forceToPoint(center),
        position: center,
        hitTest: (BoxHitTestResult result, Offset position) {
          assert(position == center);
          return child!.hitTest(result, position: center);
        },
      );
    } else {
      return false;
    }
    
  }
}
