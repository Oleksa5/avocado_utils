import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

Rect paintBounds(RenderBox renderBox, [ RenderObject? ancestor ]) {
  final transformation = renderBox.getTransformTo(ancestor);
  final rect = renderBox.paintBounds;
  final leftTop = transformation.transform3(Vector3(rect.left, rect.top, 0));
  final rightBottom = transformation.transform3(Vector3(rect.right, rect.bottom, 0));
  return Rect.fromLTRB(leftTop.x, leftTop.y, rightBottom.x, rightBottom.y);
}

Rect globalRectToLocal(Rect globalRect, { required RenderBox localTo }) {
  final Offset leftTop = localTo.globalToLocal(globalRect.topLeft);
  return Rect.fromLTWH(leftTop.dx, leftTop.dy, globalRect.width, globalRect.height);
}

String offsetToString(Offset offset, { int fractionDigits = 3 }) {
  return 'Offset(${offset.dx.toStringAsFixed(fractionDigits)}, ${offset.dy.toStringAsFixed(fractionDigits)})';
}