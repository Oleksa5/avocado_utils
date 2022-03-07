import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'flutter_graphics.dart';

class SnapEffect extends SingleChildRenderObjectWidget {
  const SnapEffect({ 
    Key? key,
    required Widget child 
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSnapEffect(MediaQuery.of(context).devicePixelRatio);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSnapEffect renderObject) {
    renderObject.devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  }
}

class RenderSnapEffect extends RenderProxyBox {
  RenderSnapEffect(this.devicePixelRatio);

  double devicePixelRatio;

  @override
  void paint(PaintingContext context, Offset offset) { 
    if (child != null) {
      offset = roundDevicePixelsOfLogicalPixelsOffset(
        offset, devicePixelRatio: devicePixelRatio
      );
      context.paintChild(child!, offset);
    }
  }
}