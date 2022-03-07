import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ActiveMouseTracker extends StatefulWidget {
  const ActiveMouseTracker({ 
    Key? key,
    required this.child 
  }) : super(key: key);

  final Widget child;

  static bool? mouseIsActive(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ActiveMouseTrackerScope>()?.state.mouseIsActive;
  }

  @override
  _ActiveMouseTrackerState createState() => _ActiveMouseTrackerState();
}

class _ActiveMouseTrackerScope extends InheritedWidget {
  const _ActiveMouseTrackerScope({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final _ActiveMouseTrackerState state;

  @override
  bool updateShouldNotify(_ActiveMouseTrackerScope old) => false;
}

bool debugCheckHasActiveMouseTracker(BuildContext context) {
  assert(
    context.dependOnInheritedWidgetOfExactType<_ActiveMouseTrackerScope>() != null, 
    '${context.widget.runtimeType} widget requires an ActiveMouseTracker widget ancestor, but none was found.'
  );
  return true;
}

class _ActiveMouseTrackerState extends State<ActiveMouseTracker> {
  late bool _mouseIsActive;
  bool get mouseIsActive => _mouseIsActive;

  @override
  void initState() {
    super.initState();
    bool mouseIsConnected = RendererBinding.instance!.mouseTracker.mouseIsConnected;
    if (mouseIsConnected) {
      _mouseIsActive = true;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
        case TargetPlatform.linux:          
          _mouseIsActive = true;
          break;
        default: 
          _mouseIsActive = false;
      }
    }
    GestureBinding.instance!.pointerRouter.addGlobalRoute(_handlePointerEvent);  
  }

  void _handlePointerEvent(PointerEvent event) {
    bool mouseIsActive = 
      event.kind == PointerDeviceKind.mouse || 
      RendererBinding.instance!.mouseTracker.mouseIsConnected;

    if (mouseIsActive != this.mouseIsActive) 
      setState(() {
        _mouseIsActive = mouseIsActive;
      });
  }

  @override
  Widget build(BuildContext context) {
    return _ActiveMouseTrackerScope(
      state: this,
      child: widget.child
    );
  }
 
  @override
  void dispose() {
    GestureBinding.instance!.pointerRouter.removeGlobalRoute(_handlePointerEvent);    
    super.dispose();
  }
}