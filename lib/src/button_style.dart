import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'resolver.dart';
import 'material_state.dart';

ButtonStyle buttonStyleFrom({
  Color? foregroundColor,
  Color? backgroundColor,
  Color? hoverColor,
  Color? pressColor,
  Color? selectionColor,
  Color? focusColor,
  Color? shadowColor,
  double? elevation,
  TextStyle? textStyle,
  EdgeInsetsGeometry? padding,
  Size? minimumSize,
  Size? fixedSize,
  Size? maximumSize,
  BorderSide? side,
  OutlinedBorder? shape,
  MouseCursor? enabledMouseCursor,
  MouseCursor? disabledMouseCursor,
  VisualDensity? visualDensity,
  MaterialTapTargetSize? tapTargetSize,
  Duration? animationDuration,
  bool? enableFeedback,
  AlignmentGeometry? alignment,
  InteractiveInkFeatureFactory? splashFactory,
}) {
  final MaterialStateProperty<Color?>? foregroundColorStateProperty = 
    foregroundColor != null ? ButtonDefaultForeground(foregroundColor) : null;

  final MaterialStateProperty<MouseCursor>? mouseCursor =
    enabledMouseCursor != null && disabledMouseCursor != null ?
      ButtonDefaultMouseCursor(enabledMouseCursor, disabledMouseCursor) : null;

  return ButtonStyle(
    textStyle: MaterialStatePropertyAll.orNull(textStyle),
    backgroundColor: MaterialStatePropertyAll.orNull(backgroundColor),
    foregroundColor: foregroundColorStateProperty,
    overlayColor: ButtonRichStateProperty.onNull(hoverColor, pressColor, selectionColor, focusColor),
    shadowColor: MaterialStatePropertyAll.orNull(shadowColor),
    elevation: MaterialStatePropertyAll.orNull(elevation),
    padding: MaterialStatePropertyAll.orNull(padding),
    minimumSize: MaterialStatePropertyAll.orNull(minimumSize),
    fixedSize: MaterialStatePropertyAll.orNull(fixedSize),
    maximumSize: MaterialStatePropertyAll.orNull(maximumSize),
    side: MaterialStatePropertyAll.orNull(side),
    shape: MaterialStatePropertyAll.orNull(shape),
    mouseCursor: mouseCursor,
    visualDensity: visualDensity,
    tapTargetSize: tapTargetSize,
    animationDuration: animationDuration,
    enableFeedback: enableFeedback,
    alignment: alignment,
    splashFactory: splashFactory,
  );
}

class ButtonRichStateProperty<T> extends MaterialStateProperty<T?> {
  ButtonRichStateProperty(
    this.hover, 
    this.press, 
    this.selection, 
    this.focus
  );

  static ButtonRichStateProperty<T>? onNull<T>(T? hovered, T? pressed, T? selected, T? focused) {
    if (hovered == null && pressed == null && selected == null && focused == null) return null;
    return ButtonRichStateProperty(hovered, pressed, selected, focused);
  }

  final T? hover; 
  final T? press;
  final T? selection;
  final T? focus;

  @override
  T? resolve(Set<MaterialState> states) {
    assert(states.length == 1, 'Supposed to be resolved with one state at a time.');
    if (states.contains(MaterialState.hovered))
      return hover;
    if (states.contains(MaterialState.pressed))
      return press;
    if (states.contains(MaterialState.selected))
      return selection;
    if (states.contains(MaterialState.focused))
      return focus;
    return null;
  }

  @override
  int get hashCode => Object.hash(
    hover, press, selection, focus
  );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is ButtonRichStateProperty
        && other.hover == hover
        && other.press == press
        && other.selection == selection
        && other.focus == focus;
  }

  @override
  String toString() {
    return 
      '{ hovered: $hover; pressed: $press; selected: $selection; '
      'focused: $focus; otherwise: null }';
  }
}

@immutable
class ButtonDefaultForeground extends MaterialStateProperty<Color?> {
  ButtonDefaultForeground(this.foregroundColor);

  final Color? foregroundColor;

  @override
  Color? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled))
      return foregroundColor?.withOpacity(0.38);
    return foregroundColor;
  }

  @override
  int get hashCode => foregroundColor.hashCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is ButtonDefaultForeground
        && other.foregroundColor == foregroundColor;
  }

  @override
  String toString() {
    return '{ disabled: ${foregroundColor?.withOpacity(0.38)}, otherwise: $foregroundColor }';
  }
}

@immutable
class ButtonDefaultMouseCursor extends MaterialStateProperty<MouseCursor>
    with Diagnosticable {
  ButtonDefaultMouseCursor(this.enabledCursor, this.disabledCursor);

  final MouseCursor enabledCursor;
  final MouseCursor disabledCursor;

  @override
  MouseCursor resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) 
      return disabledCursor;
    return enabledCursor;
  }

  @override
  int get hashCode => Object.hash(
    enabledCursor, disabledCursor
  );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is ButtonDefaultMouseCursor
        && other.enabledCursor == enabledCursor
        && other.disabledCursor == disabledCursor;
  }
}

MaterialStateProperty<T?>? resolveButtonRichStateProperty<T>(
  MaterialStateProperty<T?>? first, MaterialStateProperty<T?>? second, MaterialStateProperty<T?>? third
) {
  final resolve = makeResolver(first, second, third);
  return ButtonRichStateProperty.onNull(
    resolve((prop) => prop.resolve({MaterialState.hovered})),
    resolve((prop) => prop.resolve({MaterialState.pressed})),
    resolve((prop) => prop.resolve({MaterialState.selected})),
    resolve((prop) => prop.resolve({MaterialState.focused}))
  );
}

ButtonStyle resolveButtonStyle(ButtonStyle? first, ButtonStyle? second, ButtonStyle third) 
{
  if (first == null && second == null) return third;

  final resolve = makeResolver(first, second, third);

  return ButtonStyle(
    textStyle: resolve((style) => style.textStyle),
    backgroundColor: resolve((style) => style.backgroundColor),
    foregroundColor: resolve((style) => style.foregroundColor),
    overlayColor: resolveButtonRichStateProperty(first?.overlayColor, second?.overlayColor, third.overlayColor),
    shadowColor: resolve((style) => style.shadowColor),
    elevation: resolve((style) => style.elevation),
    padding: resolve((style) => style.padding),
    minimumSize: resolve((style) => style.minimumSize),
    fixedSize: resolve((style) => style.fixedSize),
    maximumSize: resolve((style) => style.maximumSize),
    side: resolve((style) => style.side),
    shape: resolve((style) => style.shape),
    mouseCursor: resolve((style) => style.mouseCursor),
    visualDensity: resolve((style) => style.visualDensity),
    tapTargetSize: resolve((style) => style.tapTargetSize),
    animationDuration: resolve((style) => style.animationDuration),
    enableFeedback: resolve((style) => style.enableFeedback),
    alignment: resolve((style) => style.alignment),
    splashFactory: resolve((style) => style.splashFactory),
  );
}