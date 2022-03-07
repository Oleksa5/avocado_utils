import 'package:flutter/material.dart';
import 'active_mouse_tracker.dart';

bool deviceIsMobile(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
      return false;
    default: 
      return true;
  }
}

bool shouldOptimizeComponentsSizeForTouch(BuildContext context) {
  if (deviceIsMobile(context)) {
    return true;
  } else {
    bool? mouseIsActive = ActiveMouseTracker.mouseIsActive(context);
    if (mouseIsActive != null) {
      return !mouseIsActive;
    } else {
      return false;
    }
  }
}