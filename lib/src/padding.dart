import 'package:flutter/widgets.dart';

const infiniteDirectionalInsets = EdgeInsetsDirectional.fromSTEB(
  double.infinity, double.infinity, double.infinity, double.infinity
);

EdgeInsetsDirectional copyDirectionalInsets(
  EdgeInsetsDirectional insets, {
  double? start, double? top, double? end, double? bottom, 
}) {
  return EdgeInsetsDirectional.fromSTEB(
    start ?? insets.start,
    top ?? insets.top,
    end ?? insets.end,
    bottom ?? insets.bottom
  );
}

EdgeInsetsDirectional clampDirectionalInsets(
  EdgeInsetsDirectional insets, [
  EdgeInsetsDirectional min = EdgeInsetsDirectional.zero, 
  EdgeInsetsDirectional max = infiniteDirectionalInsets
]) {
  return EdgeInsetsDirectional.fromSTEB(
    insets.start.clamp(min.start, max.start), 
    insets.top.clamp(min.top, max.top), 
    insets.end.clamp(min.end, max.end), 
    insets.bottom.clamp(min.bottom, max.bottom)
  );
}

abstract class OverlappedPaddingWidget implements Widget {
  EdgeInsetsDirectional overlappedPadding(BuildContext context);
}

EdgeInsetsDirectional subtractOverlappedPaddingIfAny(
  EdgeInsetsDirectional padding, Widget child, BuildContext context
) {
  if (child is OverlappedPaddingWidget) {
    EdgeInsetsDirectional? overlappedPadding;
    overlappedPadding = child.overlappedPadding(context);
    return padding.subtract(overlappedPadding) as EdgeInsetsDirectional;
  } else {
    return padding;
  }
}

class OverlappedPadding extends StatelessWidget implements OverlappedPaddingWidget {
  const OverlappedPadding({ 
    Key? key,
    this.padding,
    required this.child
  }) : super(key: key);

  final EdgeInsetsDirectional? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;

  @override
  EdgeInsetsDirectional overlappedPadding(BuildContext context) {
    return padding ?? EdgeInsetsDirectional.zero;
  }
}