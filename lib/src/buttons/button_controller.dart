import 'package:flutter/foundation.dart';

class ButtonController {
  int _pointerIsDownCount = 0;
  int _pointerHasEnteredCount = 0;

  bool _pressed = false;
  bool get pressed => _pressed;
  @protected
  set pressed(bool value) {
    if (value != _pressed) {
      _pressed = value;
      onPressedChange?.call(value);
    }
  }

  ValueChanged<bool>? onPressedChange;

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (value == enabled) 
      return;
    _enabled = value;
    if (enabled) {
      if (_pointerIsDownCount > 0) 
        _press();
    } else {
      _forceRelease();
    }
  }

  void press() {
    _pointerIsDownCount++;
    assert(enabled || !pressed);
    if (enabled)
      _press();
  }

  void _press() {
    pressed = true;
  } 

  void release() {
    _pointerIsDownCount--;
    assert(enabled || !pressed);
    if (enabled && _pointerIsDownCount == 0)
      pressed = false;
  }

  void _forceRelease() {
    pressed = false;
  }
  
  void handleMouseEnter() {
    _pointerHasEnteredCount++;
  }

  void handleMouseExit() {
    _pointerHasEnteredCount--;
  }

  @override
  String toString() => runtimeType.toString() + '#$hashCode';
}

class MaintainedButtonController extends ButtonController {
  MaintainedButtonController({
    this.pressedOnHover = false,
    this.unpressedOnPress = false,
    this.forceLatched = false,
    this.ignore = false
  });

  bool pressedOnHover;
  /// If true, a button returns to the unpressed state 
  /// immediately after the second press, i.e. a pointer shouldn't be 
  /// released to release the button.
  bool unpressedOnPress;
  /// If true, a button can't be released by calling the press/release pair.
  /// But it can still be released by setting [latched] to false.  
  bool forceLatched;
  bool ignore;
  int _ignoredCount = 0;
  
  bool _latched = false;
  bool get latched => _latched;
  set latched(bool value) {
    assert(!value || pressed, 'Can\'t be latched without being pressed.');
    if (value != _latched) {
      _latched = value;
      if (!latched && (_pointerIsDownCount == 0 || _pointerHasEnteredCount == 0))
        pressed = false;
    }
  }


  @override
  void press() {
    if (ignore) { 
      _ignoredCount++;
      return;
    } else {
      super.press();
    }
  }

  @override
  void _press() {
    if (!latched) {
      pressed = true;
      _latched = true;
    } else {
      if (!forceLatched) {
        _latched = false;
        if (unpressedOnPress)
          pressed = false;
      }
    }
  }

  @override
  void release() {
    if (_ignoredCount > 0) {
      _ignoredCount--;
    } else {
      _pointerIsDownCount--;
      if (_pointerIsDownCount == 0 && !latched)
        pressed = false;   
    }
  }

  @override
  void _forceRelease() {
    latched = false;
    pressed = false;
  }

  @override
  void handleMouseEnter() {
    super.handleMouseEnter();
    if (pressedOnHover && !latched) {
      press();
      release();
    }
  }
}