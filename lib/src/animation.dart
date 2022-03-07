import 'package:flutter/widgets.dart';

class CompletedAnimation extends Animation<double> {
  const CompletedAnimation();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;

  @override
  double get value => 1.0;
}