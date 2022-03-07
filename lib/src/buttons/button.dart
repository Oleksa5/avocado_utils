import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../flutter_utilities.dart';
import '../resolver.dart';
import '../animated_state.dart';
import '../input_padding.dart';
import '../lerp.dart';
import '../material_state.dart';
import '../defaults.dart';
import '../ink_response.dart' as avocado;
import '../ink_response.dart';
import 'button_controller.dart';
import 'extended_button_style.dart';

export 'button_controller.dart';

abstract class Button extends StatefulWidget {
  const Button({
    Key? key,
    this.onTap,
    this.onLongPress, 
    this.onPressed,
    this.onReleased,
    this.intent, 
    this.shortcutActivator,
    this.targetContext,
    this.type = ButtonType.momentary,
    this.style,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.controller,
    required this.child,
  }) : 
    super(key: key);

  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;
  final Intent? intent;
  final ShortcutActivator? shortcutActivator;
  final BuildContext? targetContext;
  final ButtonType type;
  final ExtendedButtonStyle? style;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final ButtonController? controller;
  final Widget child;

  bool get enabled {
    return onTap != null ||
      onLongPress != null ||
      onPressed != null ||
      intent != null ||
      shortcutActivator != null;
  }

  ExtendedButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ExtendedButtonStyle(
      textStyle: MaterialStatePropertyAll(theme.textTheme.button),
      shadowColor: MaterialStatePropertyAll(theme.shadowColor),
      elevation: MaterialStatePropertyAll(0.0),
      padding: MaterialStatePropertyAll(
        ButtonStyleButton.scaledPadding(
          const EdgeInsets.all(kButtonPadding),
          const EdgeInsets.symmetric(horizontal: kButtonPadding),
          const EdgeInsets.symmetric(horizontal: kButtonPadding / 2),
          MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        )
      ),
      minimumSize: MaterialStatePropertyAll(kMinButtonSize),
      maximumSize: MaterialStatePropertyAll(kMaxButtonSize),
      mouseCursor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) 
          return SystemMouseCursors.forbidden;
        return SystemMouseCursors.click;      
      }),
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
      margin: MaterialStatePropertyAll(kButtonMargin),
      splashingEnabled: true
    );
  }

  ExtendedButtonStyle? themeStyleOf(BuildContext context);

  @override
  State<Button> createState() => _ButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
    properties.add(DiagnosticsProperty<ExtendedButtonStyle>('style', style, defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode, defaultValue: null));
  }
}

class _ButtonState extends State<Button> 
    with MaterialStateMixin, TickerProviderStateMixin, AnimatedStateMixin {
  final backgroundColorTween = MaterialStateColorTween();
  final foregroundColorTween = MaterialStateColorTween();
  final minimumSizeTween = MaterialStateSizeTween();
  final fixedSizeTween = MaterialStateSizeTween();
  final maximumSizeTween = MaterialStateSizeTween();
  late final ButtonController controller;

  @override
  void initState() {
    super.initState();
    setMaterialState(MaterialState.disabled, !widget.enabled);
    controller = widget.controller ?? (
      widget.type == ButtonType.momentary ?
        ButtonController() :
        MaintainedButtonController()
    );
  }

  @override
  void didUpdateWidget(Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    setMaterialState(MaterialState.disabled, !widget.enabled);
    controller.enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final ExtendedButtonStyle? widgetStyle = widget.style;
    final ExtendedButtonStyle? themeStyle = widget.themeStyleOf(context);
    final ExtendedButtonStyle defaultStyle = widget.defaultStyleOf(context);

    final effectiveValue = makeResolver(widgetStyle, themeStyle, defaultStyle);
    final effectiveValue2 = makeResolver(themeStyle, defaultStyle);

    T? resolve<T>(MaterialStateProperty<T?>? Function(ExtendedButtonStyle style) getProperty) {
      return effectiveValue((ExtendedButtonStyle style) => getProperty(style)?.resolve(materialStates));
    }

    T? resolve2<T>(MaterialStateProperty<T?>? Function(ExtendedButtonStyle style) getProperty) {
      return effectiveValue2((ExtendedButtonStyle style) => getProperty(style)?.resolve(materialStates));
    }

    T? resolveTween<T>(Tween<MaterialStateProperty<T?>?> tween) {
      return evaluate(tween)?.resolve(materialStates);
    }

    animationDuration = effectiveValue((style) => style.animationDuration)!;
    updateTweens((visitor) { 
      visitor(backgroundColorTween, widget.style?.backgroundColor);
      visitor(foregroundColorTween, widget.style?.foregroundColor);
      visitor(minimumSizeTween, widget.style?.minimumSize);
      visitor(fixedSizeTween, widget.style?.fixedSize);
      visitor(maximumSizeTween, widget.style?.maximumSize);
    });

    final TextStyle? textStyle                = resolve((style) => style.textStyle);
    final Color? backgroundColor              = resolveTween(backgroundColorTween) ?? resolve2((style) => style.backgroundColor);
    final Color? foregroundColor              = resolveTween(foregroundColorTween) ?? resolve2((style) => style.foregroundColor);
    final Color? shadowColor                  = resolve((style) => style.shadowColor);
    final double? elevation                   = resolve((style) => style.elevation);
    final EdgeInsetsGeometry? padding         = resolve((style) => style.padding);
    final Size minimumSize                    = resolveTween(minimumSizeTween) ?? resolve2((style) => style.minimumSize)!;
    final Size? fixedSize                     = resolveTween(fixedSizeTween) ?? resolve2((style) => style.fixedSize);
    final Size maximumSize                    = resolveTween(maximumSizeTween) ?? resolve2((style) => style.maximumSize)!;
    final BorderSide? side                    = resolve((style) => style.side);
    final OutlinedBorder? shape               = resolve((style) => style.shape);
    final VisualDensity? visualDensity        = effectiveValue((style) => style.visualDensity)!;
    final MaterialTapTargetSize tapTargetSize = effectiveValue((style) => style.tapTargetSize)!;
    final bool? enableFeedback                = effectiveValue((style) => style.enableFeedback);
    final AlignmentGeometry alignment         = effectiveValue((style) => style.alignment)!;
    final InteractiveInkFeatureFactory? splashFactory = effectiveValue((style) => style.splashFactory);
    final double? margin                      = resolve((style) => style.margin);
    final Duration? highlightFadeDuration     = effectiveValue((style) => style.highlightFadeDuration);
    final bool splashingEnabled               = effectiveValue((style) => style.splashingEnabled)!;

    final MaterialStateProperty<Color?> overlayColor = MaterialStateProperty.resolveWith<Color?>(
      (states) => effectiveValue((style) => style.overlayColor?.resolve(states))
    );

    final MaterialStateMouseCursor resolvedMouseCursor = _MouseCursor(
      (states) => effectiveValue((style) => style.mouseCursor?.resolve(states))
    );

    Widget result = Align(
      alignment: alignment,
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: widget.child,
    );

    final Offset densityAdjustment = visualDensity!.baseSizeAdjustment;
      
    if (padding != null) {
      final double dy = densityAdjustment.dy;
      final double dx = densityAdjustment.dx;
      result = Padding(
        padding: padding.resolve(Directionality.of(context))
          .add(EdgeInsets.fromLTRB(dx, dy, dx, dy))
          .clamp(const EdgeInsets.all(kDensestPadding), EdgeInsetsGeometry.infinity),
        child: result
      );
    }

    final VoidCallback? 
      onTap = widget.onTap ?? (widget.type == ButtonType.momentary ? makePrimaryCallback() : null), 
      onPressed = widget.onPressed ?? (widget.type == ButtonType.maintained ? makePrimaryCallback() : null), 
      onReleased = widget.onReleased;

    result = avocado.InkResponse(
      onTap: onTap,
      onLongPress: widget.onLongPress,
      onHoverChanged: updateMaterialState(MaterialState.hovered),
      onFocusChanged: updateMaterialState(MaterialState.focused),
      onPressedChanged: (pressed) {
        pressed ? onPressed?.call() : onReleased?.call();
        setMaterialState(MaterialState.pressed, pressed);
      },
      enabled: widget.enabled,
      mouseCursor: resolvedMouseCursor,
      splashingEnabled: splashingEnabled,
      contained: true,
      enableFeedback: enableFeedback ?? true,
      focusNode: widget.focusNode,
      canRequestFocus: widget.enabled,
      autofocus: widget.autofocus,
      splashFactory: splashFactory,
      color: overlayColor,
      highlightFadeDuration: highlightFadeDuration,
      customBorder: shape,
      type: widget.type,
      controller: controller,
      child: IconTheme.merge(
        data: IconThemeData(color: foregroundColor),
        child: result
      )
    );

    if (widget.tooltip != null)
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );

    BoxConstraints effectiveConstraints = BoxConstraints(
      minWidth:  max(minimumSize.width + 2 * densityAdjustment.dx, 0.0),
      minHeight: max(minimumSize.height + 2 * densityAdjustment.dy, 0.0),
      maxWidth:  max(maximumSize.width + 2 * densityAdjustment.dx, 0.0),
      maxHeight: max(maximumSize.height + 2 * densityAdjustment.dy, 0.0),
    );
    
    if (fixedSize != null) {
      final Size effectiveFixedSize = fixedSize + densityAdjustment * 2;
      final Size size = effectiveConstraints.constrain(effectiveFixedSize);
      if (size.width.isFinite) {
        effectiveConstraints = effectiveConstraints.copyWith(
          minWidth: size.width,
          maxWidth: size.width,
        );
      }
      if (size.height.isFinite) {
        effectiveConstraints = effectiveConstraints.copyWith(
          minHeight: size.height,
          maxHeight: size.height,
        );
      }
    }

    result = ConstrainedBox(
      constraints: effectiveConstraints,
      child: Material(
        elevation: elevation!,
        textStyle: textStyle?.copyWith(color: foregroundColor),
        shape: shape!.copyWith(side: side),
        color: backgroundColor,
        shadowColor: shadowColor,
        type: backgroundColor == null ? MaterialType.transparency : MaterialType.button,
        animationDuration: animationDuration,
        clipBehavior: widget.clipBehavior,
        child: result,
      )
    );

    if (margin != null) {
      result = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: max(margin + densityAdjustment.dx, kDensestButtonMargin),
          vertical: max(margin + densityAdjustment.dy, kDensestButtonMargin)
        ),
        child: result
      );
    }

    if (shouldOptimizeComponentsSizeForTouch(context)) {
      final Size minSize;
      switch (tapTargetSize) {
        case MaterialTapTargetSize.padded:
          minSize = Size(
            kMinInteractiveDimension + 2 * densityAdjustment.dx,
            kMinInteractiveDimension + 2 * densityAdjustment.dy,
          );
          assert(minSize.width >= 0.0 && minSize.height >= 0.0);
          break;
        case MaterialTapTargetSize.shrinkWrap:
          minSize = Size.zero;
          break;
      }     

      result = InputPadding(
        minSize: minSize,
        child: result,
      );
    }

    return Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      child: result
    );
  }

  VoidCallback? makePrimaryCallback() {
    if (widget.intent != null)
      return () {
        Actions.invoke(widget.targetContext ?? context, widget.intent!);
      };
    else if (widget.shortcutActivator != null) {
      return () {
        BuildContext context = widget.targetContext ?? this.context;
        Intent? intent;
        context.visitAncestorElements((element) {
          if (element.widget is Shortcuts)
            intent = (element.widget as Shortcuts).shortcuts[widget.shortcutActivator];
          return intent == null;
        });
        assert(intent != null, 'Can\'t find an intent of the given shortcut activator. If you don\'t '
        'provide an onPressed callback or intent, Button can find the intent from an ambient '
        'Shortcuts which you should establish.');
        Actions.invoke(context, intent!);
      };
    }
    else return null;
  }
}

class _MouseCursor extends MaterialStateMouseCursor {
  const _MouseCursor(this.resolveCallback);

  final MaterialPropertyResolver<MouseCursor?> resolveCallback;

  @override
  MouseCursor resolve(Set<MaterialState> states) => resolveCallback(states)!;

  @override
  String get debugDescription => 'ButtonStyleButton_MouseCursor';
}