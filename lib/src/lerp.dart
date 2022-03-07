import 'package:flutter/material.dart';

T? lerpIfNotNulls<T>(T? a, T? b, double t, T? Function(T, T, double) lerp) {
  if (a != null && b != null)
       return lerp(a, b, t);
  else return t < 0.5 ? a : b;
}
  
double? lerpDouble(double? a, double? b, double t) {
  if (a == b) return b;
  
  a ??= 0.0;
  b ??= 0.0;

  if (a.isInfinite) {
    if (t != 1.0)
         return a;
    else return b;
  }

  if (b.isInfinite) {
    if (t == 0.0) 
         return a;
    else return b;
  }

  return a * (1.0 - t) + b * t;
}

Color lerpColor(Color a, Color b, double t) {
  return Color.fromARGB(
    (a.alpha * (1.0 - t) + b.alpha * t).round().clamp(0, 255), 
    (a.red   * (1.0 - t) + b.red   * t).round().clamp(0, 255), 
    (a.green * (1.0 - t) + b.green * t).round().clamp(0, 255), 
    (a.blue  * (1.0 - t) + b.blue  * t).round().clamp(0, 255)
  );
}

Size? lerpSize(Size? a, Size? b, double t) {
  a ??= Size.zero;
  b ??= Size.zero;
  return Size(lerpDouble(a.width, b.width, t)!, lerpDouble(a.height, b.height, t)!);
}

EdgeInsetsGeometry? lerpEdgeInsetsGeometry(EdgeInsetsGeometry? a, EdgeInsetsGeometry? b, double t) {
  if (t == 0.0) return a;
  if (t == 1.0) return b;
  return EdgeInsetsGeometry.lerp(a, b, t);
}

VisualDensity lerpVisualDensity(VisualDensity a, VisualDensity b, double t) {
  return VisualDensity(
    horizontal: lerpDouble(a.horizontal, b.horizontal, t)!,
    vertical: lerpDouble(a.vertical, b.vertical, t)!,
  );
}

MaterialStateProperty<T?>? lerpProperties<T>(
  MaterialStateProperty<T?>? a,
  MaterialStateProperty<T?>? b, 
  double t, 
  T? Function(T?, T?, double) lerp
) {
  if (a == null && b == null) return null;
  return LerpProperties<T>(a, b, t, lerp);
}

class LerpProperties<T> implements MaterialStateProperty<T?> {
  const LerpProperties(this.a, this.b, this.t, this.lerp);

  final MaterialStateProperty<T?>? a, b;
  final double t;
  final T? Function(T?, T?, double) lerp;

  @override
  T? resolve(Set<MaterialState> states) {
    return lerp(a?.resolve(states), b?.resolve(states), t);
  }
}

class MaterialStateColorTween extends Tween<MaterialStateProperty<Color?>?> {
    MaterialStateColorTween({ 
    MaterialStateProperty<Color?>? begin, 
    MaterialStateProperty<Color?>? end
  }) : super(begin: begin, end: end);

  @override
  MaterialStateProperty<Color?>? lerp(double t) => LerpProperties<Color>(begin, end, t, Color.lerp);
}

class MaterialStateSizeTween extends Tween<MaterialStateProperty<Size?>?> {
    MaterialStateSizeTween({ 
    MaterialStateProperty<Size?>? begin, 
    MaterialStateProperty<Size?>? end
  }) : super(begin: begin, end: end);

  @override
  MaterialStateProperty<Size?>? lerp(double t) => LerpProperties<Size>(begin, end, t, Size.lerp);
}