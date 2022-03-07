
import 'package:flutter/material.dart';

SliderThemeData? mergeSliderStyles(SliderThemeData? first, SliderThemeData? second) {
  if (first == null && second == null) return null;
  if (second == null) return first;
  if (first == null) return second;

  return first.copyWith(
    trackHeight: second.trackHeight,
    activeTrackColor: second.activeTrackColor,
    inactiveTrackColor: second.inactiveTrackColor,
    disabledActiveTrackColor: second.disabledActiveTrackColor,
    disabledInactiveTrackColor: second.disabledInactiveTrackColor,
    activeTickMarkColor: second.activeTickMarkColor,
    inactiveTickMarkColor: second.inactiveTickMarkColor,
    disabledActiveTickMarkColor: second.disabledActiveTickMarkColor,
    disabledInactiveTickMarkColor: second.disabledInactiveTickMarkColor,
    thumbColor: second.thumbColor,
    overlappingShapeStrokeColor: second.overlappingShapeStrokeColor,
    disabledThumbColor: second.disabledThumbColor,
    overlayColor: second.overlayColor,
    valueIndicatorColor: second.valueIndicatorColor,
    overlayShape: second.overlayShape,
    tickMarkShape: second.tickMarkShape,
    thumbShape: second.thumbShape,
    trackShape: second.trackShape,
    valueIndicatorShape: second.valueIndicatorShape,
    rangeTickMarkShape: second.rangeTickMarkShape,
    rangeThumbShape: second.rangeThumbShape,
    rangeTrackShape: second.rangeTrackShape,
    rangeValueIndicatorShape: second.rangeValueIndicatorShape,
    showValueIndicator: second.showValueIndicator,
    valueIndicatorTextStyle: second.valueIndicatorTextStyle,
    minThumbSeparation: second.minThumbSeparation,
    thumbSelector: second.thumbSelector,
  );
}