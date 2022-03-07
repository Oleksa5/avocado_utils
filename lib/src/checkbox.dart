import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material_lib;
import 'lerp.dart';
import 'defaults.dart';
import 'flutter_utilities.dart';

/// A checkbox based on the Flutter framework's material checkbox.
/// 
/// It allows to change the size of a rendered radio control. This is particularly 
/// useful for the desktop UI. Also [CheckboxTheme] can be used to provide a style 
/// configuration for this widget.
class Checkbox extends StatelessWidget {
  const Checkbox({ 
    Key? key,
    required this.value,
    this.tristate = false,
    required this.onChanged,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,    
    this.size
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool?> onChanged;
  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final Color? checkColor;
  final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final CheckboxStyle? checkboxStyle = CheckboxTheme.of(context); 
    double? size = this.size ?? checkboxStyle?.size; 

    if (size == null) {
      if (shouldOptimizeComponentsSizeForTouch(context)) {
        size = material_lib.Checkbox.width;
      } else {
        size = kCheckboxSize;
      }
    } 

    return Transform.scale(
      scale: size / material_lib.Checkbox.width,
      child: SizedBox(
        width: size,
        height: size,
        child: material_lib.Checkbox(
          value: value,
          tristate: tristate,
          onChanged: onChanged,
          mouseCursor: mouseCursor,
          activeColor: activeColor,
          fillColor: fillColor ?? checkboxStyle?.fillColor,
          checkColor: checkColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          overlayColor: overlayColor ?? checkboxStyle?.overlayColor,
          splashRadius: splashRadius ?? checkboxStyle?.splashRadius,
          materialTapTargetSize: materialTapTargetSize ?? checkboxStyle?.materialTapTargetSize,
          visualDensity: visualDensity ?? checkboxStyle?.visualDensity,
          focusNode: focusNode,
          autofocus: autofocus,
          shape: shape ?? checkboxStyle?.shape,
          side: side ?? checkboxStyle?.side
        )
      )
    );
  }
}

class CheckboxTheme extends InheritedWidget {
  const CheckboxTheme({ Key? key, required this.style, required Widget child }) 
    : super(key: key, child: child);

  final CheckboxStyle style;

  static CheckboxStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CheckboxTheme>()?.style;
  }

  @override
  bool updateShouldNotify(CheckboxTheme oldWidget) => style != oldWidget.style;
}

@immutable
class CheckboxStyle with Diagnosticable {
  CheckboxStyle({
    MaterialStateProperty<MouseCursor?>? mouseCursor,
    MaterialStateProperty<Color?>? fillColor,
    MaterialStateProperty<Color?>? checkColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity, 
    OutlinedBorder? shape,
    BorderSide? side,
    this.size,
    CheckboxThemeData? baseStyle
  }) :
    _baseStyle = baseStyle ?? CheckboxThemeData(
      mouseCursor: mouseCursor,
      fillColor: fillColor,
      checkColor: checkColor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      materialTapTargetSize: materialTapTargetSize,
      visualDensity: visualDensity,
      shape: shape,
      side: side
    );

  final CheckboxThemeData _baseStyle;
  MaterialStateProperty<MouseCursor?>? get mouseCursor => _baseStyle.mouseCursor;
  MaterialStateProperty<Color?>? get fillColor => _baseStyle.fillColor;
  MaterialStateProperty<Color?>? get checkColor => _baseStyle.checkColor;
  MaterialStateProperty<Color?>? get overlayColor => _baseStyle.overlayColor;
  double? get splashRadius => _baseStyle.splashRadius;
  MaterialTapTargetSize? get materialTapTargetSize => _baseStyle.materialTapTargetSize;
  VisualDensity? get visualDensity => _baseStyle.visualDensity;
  OutlinedBorder? get shape => _baseStyle.shape;
  BorderSide? get side => _baseStyle.side;
  final double? size;

  CheckboxStyle copyWith({ 
    MaterialStateProperty<MouseCursor?>? mouseCursor,
    MaterialStateProperty<Color?>? fillColor,
    MaterialStateProperty<Color?>? checkColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity, 
    OutlinedBorder? shape,
    BorderSide? side,
    double? size,
  }) {
    return CheckboxStyle(
      size: size ?? this.size,
      baseStyle: _baseStyle.copyWith(
        mouseCursor: mouseCursor,
        fillColor: fillColor,
        checkColor: checkColor,
        overlayColor: overlayColor,
        splashRadius: splashRadius,
        materialTapTargetSize: materialTapTargetSize,
        visualDensity: visualDensity,
        shape: shape,
        side: side
      )
    );
  }

  @override
  int get hashCode => Object.hash(_baseStyle, size);

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is CheckboxStyle
        && other._baseStyle == _baseStyle
        && other.size == size;
  }

  static CheckboxStyle lerp(CheckboxStyle a, CheckboxStyle b, double t) {
    return CheckboxStyle(
      size: lerpIfNotNulls(a.size, b.size, t, lerpDouble),
      baseStyle: CheckboxThemeData.lerp(a._baseStyle, b._baseStyle, t)
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _baseStyle.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double?>('size', size, defaultValue: null));
  }
}