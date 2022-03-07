import 'package:flutter/widgets.dart';

Size getHorzIntrinsicSize(RenderBox renderBox) {
  double childHeight = renderBox.getMinIntrinsicHeight(double.infinity);
  double childWidth = renderBox.getMaxIntrinsicWidth(childHeight);
  return Size(childWidth, childHeight);
}

Size getVertIntrinsicSize(RenderBox renderBox) {
  double childWidth = renderBox.getMinIntrinsicWidth(double.infinity);
  double childHeight = renderBox.getMaxIntrinsicHeight(childWidth);
  return Size(childWidth, childHeight);
}

Size layoutChild(RenderBox child, BoxConstraints constraints) {
  child.layout(constraints, parentUsesSize: true);
  return child.size;
}

bool visitRenderObjectDescendants(RenderObject renderObject, bool Function(RenderObject child) visitor) {
  bool stop = false;
  renderObject.visitChildren((child) {
    if (!stop) {
      stop = visitor(child);
      if (!stop) 
        stop = visitRenderObjectDescendants(child, visitor);
    }
  });
  return stop;
}

T? findDescendantRenderObjectOfType<T>(RenderObject renderObject) {
  T? descendant;
  visitRenderObjectDescendants(renderObject, (_descendant) {
    if (_descendant is T) {
      descendant = _descendant as T;
      return true;
    } else {
      return false;
    }
  });

  return descendant;
}

void visitRenderObjectAncestors(RenderObject renderObject, void Function(RenderObject) visitor) {
  assert(renderObject.parent is RenderObject?);
  final parent = renderObject.parent as RenderObject?;
  if (parent != null) {
    visitor(parent);
    visitRenderObjectAncestors(parent, visitor);
  }
}

String renderObjectAncestorChain(RenderObject renderObject, { String separator = ' ← ' }) {
  final buffer = StringBuffer();
  buffer.write(renderObject.toString());
  visitRenderObjectAncestors(
    renderObject, 
    (parent) => buffer.write(separator + parent.toString())
  );
  return buffer.toString();
}

String renderObjectWidgetAncestorChain(RenderObject renderObject, { String separator = ' ← ', bool shortDesc = true }) {
  assert(renderObject.debugCreator is DebugCreator);
  final debugCreator = renderObject.debugCreator as DebugCreator;
  final buffer = StringBuffer();
  if (shortDesc) {
    buffer.write(debugCreator.element.toStringShort());
    debugCreator.element.visitAncestorElements((element) {
      buffer.write(separator + element.toStringShort());
      return true;
    });
  } else {
    buffer.write(debugCreator.element.toString());
    debugCreator.element.visitAncestorElements((element) {
      buffer.write(separator + element.toString());
      return true;
    });
  }

  return buffer.toString();
}

void printRenderObjectAncestorChain(RenderObject renderObject) {
  // ignore: avoid_print
  print(renderObjectAncestorChain(renderObject));
}