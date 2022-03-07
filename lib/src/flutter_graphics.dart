// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:math';

import 'package:flutter/widgets.dart';

double _devicePixelRatio([ BuildContext? context ]) {
  return context != null ? 
    MediaQuery.of(context).devicePixelRatio : 
    WidgetsBinding.instance!.window.devicePixelRatio;
}

double toDevicePixels(double logicalPixels, [ BuildContext? context ]) {
  return logicalPixels * _devicePixelRatio(context);
}

double toLogicalPixels(double devicePixels, [ BuildContext? context ]) {
  return devicePixels / _devicePixelRatio(context);
}

double toDevicePixelsForRatio(double logicalPixels, { double? devicePixelRatio }) {
  return logicalPixels * (devicePixelRatio ?? WidgetsBinding.instance!.window.devicePixelRatio);
}

double toLogicalPixelsForRatio(double logicalPixels, { double? devicePixelRatio }) {
  return logicalPixels / (devicePixelRatio ?? WidgetsBinding.instance!.window.devicePixelRatio);
}

double roundDevicePixelsOfLogicalPixelsSize(
  double size, { 
  double? devicePixelRatio,
  double minDevicePixels = 0 
}) {
  const tolerance = 0.001;
  double roundedDeviceSize = toDevicePixelsForRatio(
    size + tolerance, devicePixelRatio: devicePixelRatio
  ).roundToDouble();

  return toLogicalPixelsForRatio(
    max(roundedDeviceSize, minDevicePixels), 
    devicePixelRatio: devicePixelRatio
  );
}

double roundDevicePixelsOfLogicalPixelsSizeForContext(
  double size, {
  BuildContext? context,
  double minDevicePixels = 0
}) {
  return roundDevicePixelsOfLogicalPixelsSize(
    size, 
    devicePixelRatio: _devicePixelRatio(context),
    minDevicePixels: minDevicePixels
  );
}

Offset roundDevicePixelsOfLogicalPixelsOffset(Offset offset, { double? devicePixelRatio }) {
  return Offset(
    roundDevicePixelsOfLogicalPixelsSize(offset.dx, devicePixelRatio: devicePixelRatio),
    roundDevicePixelsOfLogicalPixelsSize(offset.dy, devicePixelRatio: devicePixelRatio)
  );
}

double ceilDevicePixelsOfLogicalPixelsSize(double size, { required double devicePixelRatio }) {
  double roundedDeviceSize = toDevicePixelsForRatio(
    size, devicePixelRatio: devicePixelRatio).ceilToDouble();
  return toLogicalPixelsForRatio(roundedDeviceSize, devicePixelRatio: devicePixelRatio);
}

void printLogicalAndDevicePixels(double logicalX, [ double? logicalY, String? string ]) {
  double? deviceX, deviceY;
  
  deviceX = toDevicePixelsForRatio(
    logicalX, devicePixelRatio: WidgetsBinding.instance!.window.devicePixelRatio
  );

  if (logicalY != null)
    deviceY = toDevicePixelsForRatio(
      logicalY, devicePixelRatio: WidgetsBinding.instance!.window.devicePixelRatio
    );

  if (string != null) print(string);

  if (logicalY != null) {
    print('logical: x: $logicalX, y: $logicalY');
    print('device:  x: $deviceX, y: $deviceY ');
  } else {
    print('logical: $logicalX');
    print('device:  $deviceX');
  }

  print('');
}