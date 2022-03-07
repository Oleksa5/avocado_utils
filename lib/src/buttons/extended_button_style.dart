import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../button_style.dart';
import '../lerp.dart';
import '../resolver.dart';

@immutable
class ExtendedButtonStyle with Diagnosticable {
  ExtendedButtonStyle({
    MaterialStateProperty<TextStyle?>? textStyle,
    MaterialStateProperty<Color?>? backgroundColor,
    MaterialStateProperty<Color?>? foregroundColor,
    MaterialStateProperty<Color?>? overlayColor,
    MaterialStateProperty<Color?>? shadowColor,
    MaterialStateProperty<double?>? elevation,
    MaterialStateProperty<EdgeInsetsGeometry?>? padding,
    MaterialStateProperty<Size?>? minimumSize,
    MaterialStateProperty<Size?>? fixedSize,
    MaterialStateProperty<Size?>? maximumSize,
    MaterialStateProperty<BorderSide?>? side,
    MaterialStateProperty<OutlinedBorder?>? shape,
    MaterialStateProperty<MouseCursor?>? mouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    this.margin,
    this.highlightFadeDuration,
    this.splashingEnabled,
    ButtonStyle? baseStyle,
  }) : _baseStyle = baseStyle ?? ButtonStyle(
    textStyle: textStyle,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    overlayColor: overlayColor,
    shadowColor: shadowColor,
    elevation: elevation,
    padding: padding,
    minimumSize: minimumSize,
    fixedSize: fixedSize,
    maximumSize: maximumSize,
    side: side,
    shape: shape,
    mouseCursor: mouseCursor,
    visualDensity: visualDensity,
    tapTargetSize: tapTargetSize,
    animationDuration: animationDuration,
    enableFeedback: enableFeedback,
    alignment: alignment,
    splashFactory: splashFactory,
  );

  final ButtonStyle _baseStyle;
  MaterialStateProperty<TextStyle?>? get textStyle => _baseStyle.textStyle;
  MaterialStateProperty<Color?>? get backgroundColor => _baseStyle.backgroundColor;
  MaterialStateProperty<Color?>? get foregroundColor => _baseStyle.foregroundColor;
  MaterialStateProperty<Color?>? get overlayColor => _baseStyle.overlayColor;
  MaterialStateProperty<Color?>? get shadowColor => _baseStyle.shadowColor;
  MaterialStateProperty<double?>? get elevation => _baseStyle.elevation;
  MaterialStateProperty<EdgeInsetsGeometry?>? get padding => _baseStyle.padding;
  MaterialStateProperty<Size?>? get minimumSize => _baseStyle.minimumSize;
  MaterialStateProperty<Size?>? get fixedSize => _baseStyle.fixedSize;
  MaterialStateProperty<Size?>? get maximumSize => _baseStyle.maximumSize;
  MaterialStateProperty<BorderSide?>? get side => _baseStyle.side;
  MaterialStateProperty<OutlinedBorder?>? get shape => _baseStyle.shape;
  MaterialStateProperty<MouseCursor?>? get mouseCursor => _baseStyle.mouseCursor;
  VisualDensity? get visualDensity => _baseStyle.visualDensity;
  MaterialTapTargetSize? get tapTargetSize => _baseStyle.tapTargetSize;
  Duration? get animationDuration => _baseStyle.animationDuration;
  bool? get enableFeedback => _baseStyle.enableFeedback;
  AlignmentGeometry? get alignment => _baseStyle.alignment;
  InteractiveInkFeatureFactory? get splashFactory => _baseStyle.splashFactory;
  final MaterialStateProperty<double?>? margin;
  final Duration? highlightFadeDuration;
  /// {@macro avocado.InkResponse.splashingEnabled}
  final bool? splashingEnabled;

  ExtendedButtonStyle copyWith({
    MaterialStateProperty<TextStyle?>? textStyle,
    MaterialStateProperty<Color?>? backgroundColor,
    MaterialStateProperty<Color?>? foregroundColor,
    MaterialStateProperty<Color?>? overlayColor,
    MaterialStateProperty<Color?>? shadowColor,
    MaterialStateProperty<double?>? elevation,
    MaterialStateProperty<EdgeInsetsGeometry?>? padding,
    MaterialStateProperty<Size?>? minimumSize,
    MaterialStateProperty<Size?>? fixedSize,
    MaterialStateProperty<Size?>? maximumSize,
    MaterialStateProperty<BorderSide?>? side,
    MaterialStateProperty<OutlinedBorder?>? shape,
    MaterialStateProperty<MouseCursor?>? mouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    MaterialStateProperty<double?>? margin,
    Duration? highlightFadeDuration,
    bool? splashingEnabled
  }) {
    return ExtendedButtonStyle(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      overlayColor: overlayColor ?? this.overlayColor,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      minimumSize: minimumSize ?? this.minimumSize,
      fixedSize: fixedSize ?? this.fixedSize,
      maximumSize: maximumSize ?? this.maximumSize,
      side: side ?? this.side,
      shape: shape ?? this.shape,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      visualDensity: visualDensity ?? this.visualDensity,
      tapTargetSize: tapTargetSize ?? this.tapTargetSize,
      animationDuration: animationDuration ?? this.animationDuration,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      alignment: alignment ?? this.alignment,
      splashFactory: splashFactory ?? this.splashFactory,
      margin: margin ?? this.margin,
      highlightFadeDuration: highlightFadeDuration ?? this.highlightFadeDuration,
      splashingEnabled: splashingEnabled ?? this.splashingEnabled
    );
  }

  ExtendedButtonStyle merge(ExtendedButtonStyle? style) {
    if (style == null) return this;
    return ExtendedButtonStyle(
      baseStyle: _baseStyle.merge(style._baseStyle),
      margin: margin ?? style.margin,
      highlightFadeDuration: highlightFadeDuration ?? style.highlightFadeDuration,
      splashingEnabled: splashingEnabled ?? style.splashingEnabled
    );
  }

  static ExtendedButtonStyle? merge2(ExtendedButtonStyle? first, ExtendedButtonStyle? second) {
    if (first == null) return second;
    else return first.merge(second);
  }

  @override
  int get hashCode {
    return hashValues(
      _baseStyle, 
      margin,
      highlightFadeDuration,
      splashingEnabled
    );
  }

  @override
  bool operator ==(Object other) { 
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is ExtendedButtonStyle
        && other._baseStyle == _baseStyle
        && other.margin == margin
        && other.highlightFadeDuration == highlightFadeDuration
        && other.splashingEnabled == splashingEnabled;
  }


  static ExtendedButtonStyle? lerp(ExtendedButtonStyle? a, ExtendedButtonStyle? b, double t) {
    if (a == null && b == null) return null;

    return ExtendedButtonStyle(
      baseStyle: ButtonStyle.lerp(a?._baseStyle, b?._baseStyle, t)?.copyWith(
        padding: lerpProperties(a?.padding, b?.padding, t, lerpEdgeInsetsGeometry),
        maximumSize: lerpProperties(a?.maximumSize, b?.maximumSize, t, lerpSize),
        visualDensity: lerpIfNotNulls(a?.visualDensity, b?.visualDensity, t, VisualDensity.lerp)
      ),
      margin: lerpProperties(a?.margin, b?.margin, t, lerpDouble),
      highlightFadeDuration: lerpDuration(a?.highlightFadeDuration ?? Duration.zero, b?.highlightFadeDuration ?? Duration.zero, t),
      splashingEnabled: t < 0.5 ? a?.splashingEnabled : b?.splashingEnabled
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _baseStyle.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MaterialStateProperty<double?>>('margin', margin, defaultValue: null));
    properties.add(DiagnosticsProperty<Duration?>('highlightFadeDuration', highlightFadeDuration, defaultValue: null));
    properties.add(DiagnosticsProperty<bool?>('splashingEnabled', splashingEnabled, defaultValue: null));
  }
}

ExtendedButtonStyle resolveExtendedButtonStyle(ExtendedButtonStyle? first, ExtendedButtonStyle? second, ExtendedButtonStyle third) 
{
  if (first == null && second == null) return third;

  var resolve = makeResolver(first, second, third);

  return ExtendedButtonStyle(
    baseStyle: resolveButtonStyle(first?._baseStyle, second?._baseStyle, third._baseStyle),
    margin: resolve((style) => style.margin),
    highlightFadeDuration: resolve((style) => style.highlightFadeDuration),
    splashingEnabled: resolve((style) => style.splashingEnabled),
  );
}