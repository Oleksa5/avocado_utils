import 'dart:math' show max;

import 'package:flutter/material.dart';

import 'padding.dart';

class SliderOverlappedPadding extends StatelessWidget implements OverlappedPaddingWidget {
  const SliderOverlappedPadding({ 
    Key? key,
    required this.slider 
  }) : super(key: key);

  final Slider slider;

  @override
  EdgeInsetsDirectional overlappedPadding(BuildContext context) {
    final SliderThemeData sliderTheme = SliderTheme.of(context);
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final SliderComponentShape overlayShape = sliderTheme.overlayShape ?? const RoundSliderOverlayShape();
    final SliderComponentShape thumbShape = sliderTheme.thumbShape ?? const RoundSliderThumbShape();

    final isEnabled = slider.onChanged != null;
    final isDiscrete = slider.divisions != null;
    final thumbRadius = thumbShape.getPreferredSize(isEnabled, isDiscrete).width / 2;
    final thumbOverlayRadius = overlayShape.getPreferredSize(isEnabled, isDiscrete).width / 2;
    final maxRadius = max(thumbRadius, thumbOverlayRadius);
    final horzPadding = maxRadius;
    final vertPadding = maxRadius - trackHeight / 2;

    return EdgeInsetsDirectional.fromSTEB(horzPadding, vertPadding, horzPadding, vertPadding);
  }

  @override
  Widget build(BuildContext context) => slider;
}