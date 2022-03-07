import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as widgets_lib;
import 'bits.dart' as avocado;

import 'algorithms.dart';

typedef PointerEventListener = void Function(PointerEvent event);

class Listener extends StatefulWidget{
  const Listener({
    Key? key,
    this.onPointerDown,
    this.onPointerUp,
    this.onSecondaryPointerDown, 
    this.onSecondaryPointerUp, 
    this.onTertiaryPointerDown, 
    this.onTertiaryPointerUp,
    this.onPointerCancel,
    this.behavior = HitTestBehavior.deferToChild,
    this.child, 
  }) : super(key: key);

  final PointerEventListener? onPointerDown;
  final PointerEventListener? onPointerUp;
  final PointerEventListener? onSecondaryPointerDown;
  final PointerEventListener? onSecondaryPointerUp;
  final PointerEventListener? onTertiaryPointerDown;
  final PointerEventListener? onTertiaryPointerUp;
  final PointerEventListener? onPointerCancel;
  final HitTestBehavior behavior;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => PointerEventListenerState();
}

class PointerEventListenerState extends State<Listener> {
  int buttons = 0;

  // Flutter doesn't send up and down events when one button changes its state while
  // another is currently held down. Instead, it sends move events, even if the mouse is
  // not moving. To work around this, up and down events are recognized by comparing previous
  // and current events' buttons.
  //
  // The listener is called when buttons have a button bit and event.buttons don't, assuming 
  // two or more bits don't change simultaneously.   
  void notifyIfButtonsChanged(PointerEvent event) {
    VerticalDirection? direction;

    VerticalDirection? getChange(int bit) {
      bool hadBit = avocado.hasBit(buttons, bit);
      bool hasBit = avocado.hasBit(event.buttons, bit);
      
      if (hadBit != hasBit) {
        assert(direction != null, 'The current implementation assumes that two or more bits don\'t change simultaneously.');
        return !hadBit && hasBit ? VerticalDirection.down : VerticalDirection.up;
      } else {
        return null;
      }
    }

    int buttonBit;
    direction = getChange(buttonBit = kPrimaryButton);
    if (kDebugMode || direction == null) {
      direction = getChange(buttonBit = kSecondaryButton);
      if (kDebugMode || direction == null) {
        direction = getChange(buttonBit = kTertiaryButton);
      }
    }

    if (direction != null)
      notifyButtonChanged(event, buttonBit, direction);
  }

  void notifyButtonChanged(PointerEvent event, int buttonBit, VerticalDirection direction) {
    assert(
      equalsAnyOf(buttonBit, [kPrimaryButton, kSecondaryButton, kMiddleMouseButton]),
      'buttonBit is supposed to have only one bit set.'
    );
    
    switch (buttonBit) {
      case kPrimaryButton:
        direction == VerticalDirection.down ?
          widget.onPointerDown?.call(event) :
          widget.onPointerUp?.call(event);
        break;
    case kSecondaryButton:
      direction == VerticalDirection.down ?
        widget.onSecondaryPointerDown?.call(event) :
        widget.onSecondaryPointerUp?.call(event);
      break;
    case kTertiaryButton:
      direction == VerticalDirection.down ?
        widget.onTertiaryPointerDown?.call(event) :
        widget.onTertiaryPointerUp?.call(event);
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widgets_lib.Listener(
      onPointerDown: (event) {
        notifyButtonChanged(event, event.buttons, VerticalDirection.down);
        buttons = event.buttons;
      },
      onPointerMove: (event) {
        notifyIfButtonsChanged(event);
        buttons = event.buttons;
      },
      onPointerUp: (event) {
        notifyButtonChanged(event, buttons, VerticalDirection.up);
        buttons = event.buttons;
      },
      onPointerCancel: (event) {
        widget.onPointerCancel?.call(event);
        buttons = event.buttons;
      },
      behavior: widget.behavior,
      child: widget.child,
    );
  }
}