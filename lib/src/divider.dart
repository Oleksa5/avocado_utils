import 'package:flutter/material.dart';
import 'defaults.dart';
import 'flutter_graphics.dart';
import 'snap_effect.dart';

/// Similar to the Flutter framework Divider, except it uses
/// [SnapEffect] to align a divider's line with device pixels
/// if the line fits into a pixel grid.
class Divider extends StatelessWidget {
  /// For [height] or [thickness] less than one device pixel, 
  /// the resulting line's height is one device pixel.
  const Divider({
    Key? key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  }) : assert(height == null || height >= 0.0),
       assert(thickness == null || thickness >= 0.0),
       assert(indent == null || indent >= 0.0),
       assert(endIndent == null || endIndent >= 0.0),
       super(key: key);

  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DividerThemeData dividerTheme = DividerTheme.of(context);
    final densityAdjustment = theme.visualDensity.baseSizeAdjustment;

    double height = this.height ?? dividerTheme.space ?? kPadding;
    height += densityAdjustment.dy;
    double _height = toDevicePixels(height);
    double oneDevicePixel = toLogicalPixels(1.0, context);
    if (_height < 1.0) height = oneDevicePixel;

    double thickness = this.thickness ?? dividerTheme.thickness ?? 0.0;
    double _thickness = toDevicePixels(thickness, context);
    if (_thickness < 1.0) thickness = oneDevicePixel;

    final double indent = this.indent ?? dividerTheme.indent ?? 0.0;
    final double endIndent = this.endIndent ?? dividerTheme.endIndent ?? 0.0;

    final Color? effectiveColor = color ?? dividerTheme.color ?? Theme.of(context).dividerColor;

    Widget result = SizedBox(
      height: thickness,
      width: double.infinity,
      child: ColoredBox(
        color: effectiveColor!,
      ),
    );

    const tolerance = 0.1;
    double _roundedThickness = _thickness.roundToDouble();
    if (_height <= 1 ||
        (_thickness >= _roundedThickness - tolerance &&
        _thickness <= _roundedThickness + tolerance))
      result = SnapEffect(child: result);

    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
            child: result
        ),
      ),
    );
  }
}