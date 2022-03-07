import 'package:flutter/material.dart';

import '../ink_response.dart';
import '../material_state.dart';
import 'button.dart';
import 'extended_button_style.dart';

class IconButton extends Button {
  const IconButton({
    Key? key,
    VoidCallback? onPressed,
    VoidCallback? onReleased,
    VoidCallback? onLongPress,
    Intent? intent,
    ShortcutActivator? shortcutActivator,
    BuildContext? targetContext,
    ButtonType type = ButtonType.momentary,
    ExtendedButtonStyle? style,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    String? tooltip,
    ButtonController? controller,
    required Widget child
  }) : super(
    key: key,
    onPressed: onPressed,
    onReleased: onReleased,
    onLongPress: onLongPress, 
    intent: intent, 
    shortcutActivator: shortcutActivator,
    targetContext: targetContext,
    type: type,
    style: style,
    focusNode: focusNode,
    autofocus: autofocus,
    clipBehavior: clipBehavior,
    tooltip: tooltip,
    controller: controller,
    child: child,
  );

  @override
  ExtendedButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return super.defaultStyleOf(context).copyWith(
      foregroundColor: MaterialStatePropertyAll(colorScheme.onSurface),
      backgroundColor: MaterialStatePropertyAll(Colors.transparent),
      overlayColor: MaterialStateProperty.resolveWith((states) { 
        
      }),
      elevation: MaterialStatePropertyAll(0.0),
      shape: MaterialStatePropertyAll(
        const CircleBorder(side: BorderSide(style: BorderStyle.none))
      ),
    );
  }

  @override
  ExtendedButtonStyle? themeStyleOf(BuildContext context) {
    return IconButtonTheme.of(context);
  }
}

class IconButtonTheme extends InheritedTheme {
  const IconButtonTheme({
    Key? key,
    required this.style,
    required Widget child
  }) : super(key: key, child: child);

  final ExtendedButtonStyle style;

  static ExtendedButtonStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<IconButtonTheme>()?.style;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return IconButtonTheme(style: style, child: child);
  }

  @override
  bool updateShouldNotify(IconButtonTheme oldWidget) {
    return style != oldWidget.style;
  }
}