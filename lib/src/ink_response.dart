import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'buttons/button_controller.dart';
import 'listener.dart' as avocado;

enum ButtonType {
  momentary, maintained
}

/// A version of the Flutter framework InkResponse that allows to customize 
/// [highlightFadeDuration] and can be of a maintained button type. It also
/// can take a [controller] which gives more control over the state of an ink 
/// response to ancestor widgets.
class InkResponse extends StatefulWidget {
  const InkResponse({
    Key? key,
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHoverChanged,
    this.onFocusChanged,
    this.onPressedChanged,
    this.enabled = true,
    this.mouseCursor,
    this.splashingEnabled = true,
    this.contained = false,
    this.highlightShape = BoxShape.rectangle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.highlightFadeDuration,
    this.color,
    this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.type = ButtonType.momentary,
    this.controller
  }) : super(key: key);

  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final ValueChanged<bool>? onHoverChanged;
  final ValueChanged<bool>? onFocusChanged;
  /// Called when a ink response changes its state from pressed 
  /// to released or vice versa.
  final ValueChanged<bool>? onPressedChanged;
  final bool enabled;
  final MouseCursor? mouseCursor;
  /// {@template avocado.InkResponse.enableSplashing}
  /// Whether taps cause splashes. If false, a press
  /// is expressed by a simple highlight change.
  /// {@endtemplate}
  final bool splashingEnabled;
  final bool contained;
  final BoxShape highlightShape;
  final double? radius;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Duration? highlightFadeDuration;
  final MaterialStateProperty<Color?>? color;
  final InteractiveInkFeatureFactory? splashFactory;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final ButtonType type;
  final ButtonController? controller;

  @mustCallSuper
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasDirectionality(context));
    return true;
  }

  RectCallback? getRectCallback(RenderBox referenceBox) => null;

  @override
  _InkResponseState createState() => _InkResponseState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onDoubleTap != null) 'double tap',
      if (onLongPress != null) 'long press',
      if (onTapDown != null) 'tap down',
      if (onTapCancel != null) 'tap cancel',
    ];
    properties.add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'));
    properties.add(DiagnosticsProperty<MouseCursor>('mouseCursor', mouseCursor));
    properties.add(DiagnosticsProperty<bool>('containedInkWell', contained, level: DiagnosticLevel.fine));
    properties.add(DiagnosticsProperty<BoxShape>(
      'highlightShape',
      highlightShape,
      description: '${contained ? "clipped to " : ""}$highlightShape',
      showName: false,
    ));
  }
}

mixin _ParentInkResponseStateMixin<T extends StatefulWidget> on State<T> {
  final ObserverList<_ParentInkResponseStateMixin> _activeChildren = ObserverList<_ParentInkResponseStateMixin>();
  bool get _anyChildInkResponsePressed => _activeChildren.isNotEmpty;

  void markChildInkResponsePressed(_ParentInkResponseStateMixin childState, bool value) {
    final bool lastAnyPressed = _anyChildInkResponsePressed;
    if (value)
      _activeChildren.add(childState);
    else
      _activeChildren.remove(childState);
    final bool nowAnyPressed = _anyChildInkResponsePressed;
    if (nowAnyPressed != lastAnyPressed)
      _ParentInkResponseProvider.of(context)?.markChildInkResponsePressed(this, nowAnyPressed);
  }
}

class _ParentInkResponseProvider extends InheritedWidget {
  const _ParentInkResponseProvider({
    required this.state,
    required Widget child,
  }) : super(child: child);

  final _ParentInkResponseStateMixin state;

  @override
  bool updateShouldNotify(_ParentInkResponseProvider oldWidget) {
    assert(state == oldWidget.state);
    return false;
  }

  static _ParentInkResponseStateMixin? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ParentInkResponseProvider>()?.state;
  }
}

enum _HighlightType {
  hover, 
  focus, 
  press
}

class _InkResponseState extends State<InkResponse> with AutomaticKeepAliveClientMixin<InkResponse>, _ParentInkResponseStateMixin {
  Set<InteractiveInkFeature>? _splashes;
  InteractiveInkFeature? _currentSplash;
  bool _hovering = false;
  late ButtonController controller;
  final Map<_HighlightType, InkHighlight?> _highlights = <_HighlightType, InkHighlight?>{};
  bool get highlightsExist => _highlights.values.where((InkHighlight? highlight) => highlight != null).isNotEmpty;
  @override
  bool get wantKeepAlive => highlightsExist || (_splashes != null && _splashes!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_handleFocusHighlightModeChange);
    if (widget.controller == null) {
      switch (widget.type) {
        case ButtonType.momentary:
          controller = ButtonController();
          break;
        case ButtonType.maintained:
          controller = MaintainedButtonController();
          break;
      }
    } else {
      assert(
        (widget.type == ButtonType.momentary && widget.controller.runtimeType == ButtonController) ||
        (widget.type == ButtonType.maintained && widget.controller.runtimeType == MaintainedButtonController)
      );
      controller = widget.controller!;
    }

    controller.onPressedChange = _onPressedChanged;
  }

  @override
  void didUpdateWidget(InkResponse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      updateHighlight(_HighlightType.hover, value: _hovering && widget.enabled);
      _updateFocusHighlights();
    }

    assert(widget.controller == oldWidget.controller);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.debugCheckContext(context));
    super.build(context);

    for (final _HighlightType type in _highlights.keys)
      _highlights[type]?.color = getHighlightColorForType(type);

    _currentSplash?.color = widget.color?.resolve({MaterialState.pressed}) ?? Theme.of(context).splashColor;

    final MouseCursor effectiveMouseCursor = MaterialStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!widget.enabled) MaterialState.disabled,
        if (_hovering && widget.enabled) MaterialState.hovered,
        if (_hasFocus) MaterialState.focused,
      },
    );

    controller.enabled = widget.enabled;

    return _ParentInkResponseProvider(
      state: this,
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _simulateTap),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: _simulateTap),
        },
        child: Focus(
          focusNode: widget.focusNode,
          canRequestFocus: _canRequestFocus,
          onFocusChange: _handleFocusUpdate,
          autofocus: widget.autofocus,
          child: MouseRegion(
            cursor: effectiveMouseCursor,
            onEnter: _handleMouseEnter,
            onExit: _handleMouseExit,
            child: Semantics(
              onTap: widget.excludeFromSemantics || widget.onTap == null ? null : _simulateTap,
              onLongPress: widget.excludeFromSemantics || widget.onLongPress == null ? null : _simulateLongPress,
              child: avocado.Listener(
                onPointerDown:   (_) => controller.press(),
                onPointerUp:     (_) => controller.release(),
                onPointerCancel: (_) => controller.release(),
                child: GestureDetector(
                  onTapDown:   widget.enabled ? _handleTapDown : null,
                  onTap:       widget.enabled ? _handleTap : null,
                  onTapCancel: widget.enabled ? _handleTapCancel : null,
                  onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
                  onLongPress: widget.onLongPress != null ? _handleLongPress : null,
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    _hovering = true;
    controller.handleMouseEnter();
    if (widget.enabled && !(widget.type == ButtonType.maintained && controller.pressed))
      _handleHoverChange();
  }

  void _handleMouseExit(PointerExitEvent event) {
    _hovering = false;
    controller.handleMouseExit();
    if (widget.splashingEnabled)
      scheduleMicrotask(() {
        if (!controller.pressed) {
          _currentSplash?.cancel();
          _currentSplash = null;
        }   
      }); 
    _handleHoverChange();
  }

  void _handleHoverChange() {
    updateHighlight(_HighlightType.hover, value: _hovering);
    widget.onHoverChanged?.call(_hovering);
  }

  bool _hasFocus = false;
  void _handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    _updateFocusHighlights();
    widget.onFocusChanged?.call(hasFocus);
  }

  void _updateFocusHighlights() {
    final bool showFocus;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        showFocus = false;
        break;
      case FocusHighlightMode.traditional:
        showFocus = _shouldShowFocus;
        break;
    }
    updateHighlight(_HighlightType.focus, value: showFocus);
  }

  bool get _shouldShowFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled && _hasFocus;
      case NavigationMode.directional:
        return _hasFocus;
    }
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted)
      return;
    setState(() {
      _updateFocusHighlights();
    });
  }

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled && widget.canRequestFocus;
      case NavigationMode.directional:
        return true;
    }
  }

  void _handleTapDown([ TapDownDetails? details ]) {
    if (_anyChildInkResponsePressed)
      return;
    if (widget.splashingEnabled)
      _startSplash(details: details);
    if (details != null)
      widget.onTapDown?.call(details);
  }

  void _onPressedChanged(bool pressed) {
    if (!mounted) return;
    if (widget.type == ButtonType.maintained) {
      if (pressed)
        updateHighlight(_HighlightType.hover, value: false);
      else
        updateHighlight(_HighlightType.hover, value: _hovering && widget.enabled);
    }

    if (widget.type == ButtonType.maintained || !widget.splashingEnabled)
      updateHighlight(_HighlightType.press, value: pressed);
      
    _ParentInkResponseProvider.of(context)?.markChildInkResponsePressed(this, pressed);
    widget.onPressedChanged?.call(pressed);
  }

  void _handleTap() {
    if (widget.splashingEnabled) {
      _currentSplash?.confirm();
      _currentSplash = null;
    }
    if (widget.onTap != null) {
      if (widget.enableFeedback)
        Feedback.forTap(context);
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.splashingEnabled) {
      _currentSplash?.cancel();
      _currentSplash = null;
    }
    widget.onTapCancel?.call();
  }

  void _simulateTap([Intent? intent]) {
    if (widget.splashingEnabled)  
      _startSplash(context: context);
    controller..press()..release();
    _handleTap();
  }

  void _simulateLongPress() {
    if (widget.splashingEnabled)
      _startSplash(context: context);
    _handleLongPress();
  }

  void _handleDoubleTap() {
    assert(_currentSplash == null);
    widget.onDoubleTap?.call();
  }

  void _handleLongPress() {
    _currentSplash?.confirm();
    _currentSplash = null;   
    if (widget.onLongPress != null) {
      if (widget.enableFeedback)
        Feedback.forLongPress(context);
      widget.onLongPress!();
    }
  }

  void _startSplash({TapDownDetails? details, BuildContext? context}) {
    assert(details != null || context != null);

    final Offset globalPosition;
    if (context != null) {
      final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
      assert(referenceBox.hasSize, 'InkResponse must be done with layout before starting a splash.');
      globalPosition = referenceBox.localToGlobal(referenceBox.paintBounds.center);
    } else {
      globalPosition = details!.globalPosition;
    }
    final InteractiveInkFeature splash = _createInkFeature(globalPosition);
    _splashes ??= HashSet<InteractiveInkFeature>();
    _splashes!.add(splash);
    _currentSplash = splash;
    updateKeepAlive();
  }

  InteractiveInkFeature _createInkFeature(Offset globalPosition) {
    final MaterialInkController inkController = Material.of(context)!;
    final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
    final Offset position = referenceBox.globalToLocal(globalPosition);
    const Set<MaterialState> pressed = <MaterialState>{ MaterialState.pressed };
    final Color color = widget.color?.resolve(pressed) ?? Theme.of(context).splashColor;
    final RectCallback? rectCallback = widget.contained ? widget.getRectCallback(referenceBox) : null;
    final BorderRadius? borderRadius = widget.borderRadius;
    final ShapeBorder? customBorder = widget.customBorder;

    InteractiveInkFeature? splash;
    void onRemoved() {
      if (_splashes != null) {
        assert(_splashes!.contains(splash));
        _splashes!.remove(splash);
        if (_currentSplash == splash)
          _currentSplash = null;
        updateKeepAlive();
      }
    }

    splash = (widget.splashFactory ?? Theme.of(context).splashFactory).create(
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: widget.contained,
      rectCallback: rectCallback,
      radius: widget.radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      onRemoved: onRemoved,
      textDirection: Directionality.of(context),
    );

    return splash;
  }

  void updateHighlight(_HighlightType type, { required bool value }) {
    final InkHighlight? highlight = _highlights[type];
    void handleInkRemoval() {
      assert(_highlights[type] != null);
      _highlights[type] = null;
      updateKeepAlive();
    }

    if (value == (highlight != null && highlight.active))
      return;

    if (value) {
      if (highlight == null) {
        final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
        _highlights[type] = InkHighlight(
          controller: Material.of(context)!,
          referenceBox: referenceBox,
          color: getHighlightColorForType(type),
          shape: widget.highlightShape,
          radius: widget.radius,
          borderRadius: widget.borderRadius,
          customBorder: widget.customBorder,
          rectCallback: widget.getRectCallback(referenceBox),
          onRemoved: handleInkRemoval,
          textDirection: Directionality.of(context),
          fadeDuration: getFadeInDurationForType(type)
        );
        updateKeepAlive();
      } else {
        highlight.activate();
      }
    } else {
      highlight!.deactivate();
    }

    assert(value == (_highlights[type] != null && _highlights[type]!.active));
  }

  Color getHighlightColorForType(_HighlightType type) {
    const Set<MaterialState> hovered  = <MaterialState>{ MaterialState.hovered };
    const Set<MaterialState> focused  = <MaterialState>{ MaterialState.focused };
    const Set<MaterialState> pressed  = <MaterialState>{ MaterialState.pressed };

    switch (type) {
      case _HighlightType.hover:
        return widget.color?.resolve(hovered) ?? Theme.of(context).hoverColor;
      case _HighlightType.focus:
        return widget.color?.resolve(focused) ?? Theme.of(context).focusColor;
      case _HighlightType.press:
        return widget.color?.resolve(pressed) ?? Theme.of(context).highlightColor;
    }
  }

  Duration getFadeInDurationForType(_HighlightType type) {
    if (widget.highlightFadeDuration != null) return widget.highlightFadeDuration!;
    switch (type) {
      case _HighlightType.hover:
      case _HighlightType.focus:
        return const Duration(milliseconds: 50);
      case _HighlightType.press:
        return Duration.zero;
    }
  }

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveInkFeature> splashes = _splashes!;
      _splashes = null;
      for (final InteractiveInkFeature splash in splashes)
        splash.dispose();
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    
    for (final _HighlightType highlight in _highlights.keys) {
      _highlights[highlight]?.dispose();
      _highlights[highlight] = null;
    }
    
    _ParentInkResponseProvider.of(context)?.markChildInkResponsePressed(this, false);  
    super.deactivate();
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_handleFocusHighlightModeChange);
    super.dispose();
  }
}
