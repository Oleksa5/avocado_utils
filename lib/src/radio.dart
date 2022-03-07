import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material_lib;
import 'defaults.dart';
import 'flutter_utilities.dart';
import 'lerp.dart';

const kRadioOuterRadius = 8.0;
const kRadioStrokeWidth = 2.0;
const kMaterialRadioSize = 2 * kRadioOuterRadius + kRadioStrokeWidth;

/// A radio button based on the Flutter framework's material design radio button.
/// 
/// It allows to change the size of a rendered radio control. This is particularly 
/// useful for the desktop UI. Also [RadioTheme] can be used to provide a style 
/// configuration for this widget.
class Radio<T> extends StatelessWidget {
  const Radio({ 
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.mouseCursor,
    this.toggleable = false,
    this.activeColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.size
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final MouseCursor? mouseCursor;
  final bool toggleable;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final RadioStyle? radioStyle = RadioTheme.of(context);
    double? size = this.size ?? radioStyle?.size;
    double? splashRadius = this.splashRadius ?? radioStyle?.splashRadius;

    if (shouldOptimizeComponentsSizeForTouch(context)) {
      size ??= kMaterialRadioSize;
    } else {
      size ??= kRadioSize;
      splashRadius ??= 0.0;
    }
    
    return Transform.scale(
      scale: size / kMaterialRadioSize,
      child: SizedBox(
        width: size,
        height: size,
        child: material_lib.Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          mouseCursor: mouseCursor,
          toggleable: toggleable,
          activeColor: activeColor,
          fillColor: fillColor ?? radioStyle?.fillColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          overlayColor: overlayColor ?? radioStyle?.overlayColor,
          splashRadius: splashRadius ?? radioStyle?.splashRadius,
          materialTapTargetSize: materialTapTargetSize ?? radioStyle?.materialTapTargetSize,
          visualDensity: visualDensity ?? radioStyle?.visualDensity,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
      ),
    );
  }
}

class RadioTheme extends InheritedWidget {
  const RadioTheme({ Key? key, required this.style, required Widget child }) 
    : super(key: key, child: child);

  final RadioStyle style;

  static RadioStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RadioTheme>()?.style;
  }

  @override
  bool updateShouldNotify(RadioTheme oldWidget) => style != oldWidget.style;
}

@immutable
class RadioStyle with Diagnosticable {
  RadioStyle({
    MaterialStateProperty<MouseCursor?>? mouseCursor,
    MaterialStateProperty<Color?>? fillColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity, 
    this.size,
    RadioThemeData? baseStyle
  }) :
    _baseStyle = baseStyle ?? RadioThemeData(
      mouseCursor: mouseCursor,
      fillColor: fillColor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      materialTapTargetSize: materialTapTargetSize,
      visualDensity: visualDensity
    );

  final RadioThemeData _baseStyle;
  MaterialStateProperty<MouseCursor?>? get mouseCursor => _baseStyle.mouseCursor;
  MaterialStateProperty<Color?>? get fillColor => _baseStyle.fillColor;
  MaterialStateProperty<Color?>? get overlayColor => _baseStyle.overlayColor;
  double? get splashRadius => _baseStyle.splashRadius;
  MaterialTapTargetSize? get materialTapTargetSize => _baseStyle.materialTapTargetSize;
  VisualDensity? get visualDensity => _baseStyle.visualDensity;
  final double? size;

  RadioStyle copyWith({ 
    MaterialStateProperty<MouseCursor?>? mouseCursor,
    MaterialStateProperty<Color?>? fillColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity, 
    double? size,
  }) {
    return RadioStyle(
      size: size ?? this.size,
      baseStyle: _baseStyle.copyWith(
        mouseCursor: mouseCursor,
        fillColor: fillColor,
        overlayColor: overlayColor,
        splashRadius: splashRadius,
        materialTapTargetSize: materialTapTargetSize,
        visualDensity: visualDensity
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
    return other is RadioStyle
        && other._baseStyle == _baseStyle
        && other.size == size;
  }

  static RadioStyle lerp(RadioStyle a, RadioStyle b, double t) {
    return RadioStyle(
      size: lerpIfNotNulls(a.size, b.size, t, lerpDouble),
      baseStyle: RadioThemeData.lerp(a._baseStyle, b._baseStyle, t)
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _baseStyle.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double?>('size', size, defaultValue: null));
  }
}