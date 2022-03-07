import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class Position {
  const Position({ 
    this.origin = Alignment.topLeft, 
    this.alignment = Alignment.topLeft, 
    this.offset = Offset.zero
  });

  const Position.centered() : this(
    origin: Alignment.center,
    alignment: Alignment.center,
  ); 
  
  final Alignment origin;
  final Alignment alignment; 
  final Offset offset; 

  bool get isCentered {
    return origin == Alignment.center || alignment == Alignment.center || offset == Offset.zero;
  }

  @override
  int get hashCode => Object.hash(origin, alignment, offset);

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is Position
        && other.origin == origin  
        && other.alignment == alignment  
        && other.offset == offset;  
  }
}

class MutableRect {
  MutableRect.fromOrigin(
    Offset origin, { 
    Alignment innerAlignment = Alignment.topLeft, 
    required Size size,
    Offset offset = Offset.zero
  }) {
    Offset innerOffset = innerAlignment.alongSize(size);
    _left = origin.dx - innerOffset.dx + offset.dx;
    _top = origin.dy - innerOffset.dy + offset.dy;
    _right = left + size.width;
    _bottom = top + size.height; 
  }

  MutableRect.alignedWithinBounds(
    Rect bounds, { 
    required Size size, 
    required Alignment alignment 
  }) : this.fromOrigin(
    alignment.withinRect(bounds), 
    innerAlignment: alignment, 
    size: size
  );

  MutableRect.fromAlignmentContext(
    Rect alignmentContext, {
    Alignment originAlignment = Alignment.topLeft, 
    Alignment alignment = Alignment.topLeft, 
    required Size size,
    Offset offset = Offset.zero,
  }) : this.fromOrigin(
    originAlignment.withinRect(alignmentContext),
    innerAlignment: alignment, 
    size: size,
    offset: offset
  ); 

  double get left => _left;
  double get top => _top;
  double get right => _right;
  double get bottom => _bottom;

  Offset get leftTop => Offset(left, top);
  Offset get rightTop => Offset(left, top);
  Offset get leftBottom => Offset(left, top);
  Offset get rightBottom => Offset(left, top);

  double get width => right - left;
  double get height => bottom - top;
  
  Size get size => Size(width, height);

  bool isHorzOutside(Rect bounds) {
    return left < bounds.left || right > bounds.right;
  }

  bool isVertOutside(Rect bounds) {
    return top < bounds.top || bottom > bounds.bottom;
  }

  bool isOutside(Rect bounds) {
    return isHorzOutside(bounds) || isVertOutside(bounds);
  }

  void move({ double dx = 0, double dy = 0 }) {
    _left += dx; _right += dx;
    _top += dy; _bottom += dy;
  }

  void shift(Offset offset) {
    move(dx: offset.dx, dy: offset.dy);
  }

  void moveTo({ double? x, double? y }) {
    move(
      dx: x != null ? x - left : 0, 
      dy: y != null ? y - top : 0
    );
  }

  void moveToHaveRightAt(double x) {
    moveTo(x: x - width);
  }

  /// Moves this rect along axes by a minimum offset sufficient to 
  /// enclose it inside the given bounds. Resizes it if its size 
  /// is greater than the bounds' size.
  void ensureEnclosedBy(Rect bounds) {
    ensureHorzEnclosedBy(bounds);
    ensureVertEnclosedBy(bounds);
  }

  void ensureHorzEnclosedBy(Rect bounds) {
    if (width >= bounds.width) {
      _left = bounds.left;
      _right = bounds.right;
    } else {
      final width = this.width;
      if (right > bounds.right) {
        _right = bounds.right;
        _left = right - width;
      } 
      else if (left < bounds.left) {
        _left = bounds.left;
        _right = left + width;
      }
    }
  }

  void ensureVertEnclosedBy(Rect bounds) {
    if (height >= bounds.height) {
      _top = bounds.top;
      _bottom = bounds.bottom;
    } else {
      final height = this.height;
      if (bottom > bounds.bottom) {
        _bottom = bounds.bottom;
        _top = bottom - height;
      }
      else if (top < bounds.top) {
        _top = bounds.top;
        _bottom = top + height;
      }
    }
  }

  double localXAsAlignment(double x) => x / (width / 2) - 1.0;
  double localYAsAlignment(double y) => y / (height / 2) - 1.0;

  late double _left, _top, _right, _bottom;
}

Rect makeCollapsedRect(Offset offset) {
  return Rect.fromPoints(offset, offset);
}

Rect rectFromPoints(Offset leftTop, Offset rightBottom) {
  return Rect.fromLTRB(leftTop.dx, leftTop.dy, rightBottom.dx, rightBottom.dy);
}

Rect makeRect({ Offset offset = Offset.zero, required Size size}) {
  return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
}

Rect copyRect(Rect rect, { double? left, double? top, double? right, double? bottom }) {
  return Rect.fromLTRB(left ?? rect.left, top ?? rect.top, right ?? rect.right, bottom ?? rect.bottom);
}

Size enforceMaxSize(Size size, Size constraints) {
  double width = size.width > constraints.width ?
    constraints.width : size.width;
  double height = size.height > constraints.height ?
    constraints.height : size.height;
  return Size(width, height);
}

String rectToString(dynamic rect, { int fractionDigits = 1 }) {
  return '(l:${rect.left.toStringAsFixed(fractionDigits)} r:${rect.right.toStringAsFixed(fractionDigits)} '
         't:${rect.top.toStringAsFixed(fractionDigits)} b:${rect.bottom.toStringAsFixed(fractionDigits)})';
}