import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'render_object.dart';
import 'flutter_graphics.dart';
import 'algorithms.dart';
import 'directional.dart'; 

enum FlexingBase {
  /// Causes children to have min main size and max cross size if
  /// CrossAxisAlignment.stretch is not specified or the greatest 
  /// children size on the cross axis otherwise. 
  minIntrinsic,

  /// Causes children to have max main and min cross sizes if 
  /// CrossAxisAlignment.stretch is not specified or the greatest 
  /// min children size on the cross axis and max main size based
  /// on that cross size otherwise.
  maxIntrinsic,

  /// Child decides its base size given loose constraints: unbounded 
  /// on main axis and bounded on cross axis. 
  // childChoice
}

/// Instructs what to do if there is free space left 
/// that should be filled. 
enum MainAxisSpacing {
  /// Fill the free space. [AutoFlex] makes flexible children 
  /// fill it proportionally.
  fill, 

  /// Place the free space evenly between the children.
  spaceBetween
}

enum CrossAxisAlignment {
  /// Stretch to the greatest children size on the cross axis.
  stretch
}

/// A widget that displays its children in a one-dimensional array.
/// 
/// It is similar to [Flex], but all children is implicitly flexible.
/// To make a child inflexible, wrap it in [Inflexible]. Also you
/// can't explicitly specify a flex-factor, it is always a min intrinsic
/// main size of a particular child (though it may change in the future).
/// Children has to flex only if they overflow, otherwise you can space 
/// them by using [MainAxisSpacing.spaceBetween].
/// 
/// On the cross axis, children stretch to the largest child max
/// intrinsic cross size (subject to the incoming constraints).
/// Other options are not currently implemented.
/// 
/// [AutoFlex] can snap its children to device pixels to fix blurry 
/// appearance that may occur due to fractional flexing (this is mainly 
/// useful for the desktop). Snapping is performed in local space and 
/// for the main axis only. To enable this feature, specify [snapToDevicePixels].
class AutoFlex extends MultiChildRenderObjectWidget {
  AutoFlex({
    Key? key, required this.direction,
    required this.flexingBase,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisSpacing = MainAxisSpacing.fill,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    List<Widget> children = const <Widget>[],
    this.snapToDevicePixels = false
  }) : super(key: key, children: children);

  final Axis direction;
  final FlexingBase flexingBase;
  final MainAxisSize mainAxisSize;
  final MainAxisSpacing mainAxisSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final bool snapToDevicePixels;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAutoFlex(
      direction, 
      flexingBase,
      mainAxisSize,
      mainAxisSpacing, 
      crossAxisAlignment,
      snapToDevicePixels ? 
        MediaQuery.of(context).devicePixelRatio : null
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderAutoFlex renderObject) {
    renderObject
      ..direction = direction
      ..mainAxisSize = mainAxisSize
      ..mainAxisSpacing = mainAxisSpacing
      ..devicePixelRatio = snapToDevicePixels ? 
          MediaQuery.of(context).devicePixelRatio : null;
  }
}

class Inflexible extends ParentDataWidget<_AutoFlexParentData> {
  const Inflexible({ Key? key, required Widget child }) :
    super(key: key, child: child);

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _AutoFlexParentData);
    final parentData = renderObject.parentData as _AutoFlexParentData;
    if (!parentData.isFlexible) return;
    parentData.isFlexible = false;
    AbstractNode? renderObjectParent = renderObject.parent;
    if (renderObjectParent is RenderObject) renderObjectParent.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => AutoFlex;
}

class _AutoFlexParentData extends ContainerBoxParentData<RenderBox> {
  bool isFlexible = true;
}

class _RenderAutoFlex extends RenderBox
  with ContainerRenderObjectMixin<RenderBox, _AutoFlexParentData>,
       RenderBoxContainerDefaultsMixin<RenderBox, _AutoFlexParentData>,
       Directional, DirectionalRenderBox {

  _RenderAutoFlex(
    Axis direction, 
    FlexingBase flexingBase,
    MainAxisSize mainAxisSize, 
    MainAxisSpacing mainAxisSpacing,
    CrossAxisAlignment crossAxisAlignment,
    double? devicePixelRatio
  ) : 
    _direction = direction,
    _flexingBase = flexingBase,
    _mainAxisSize = mainAxisSize,
    _mainAxisSpacing = mainAxisSpacing,
    assert(crossAxisAlignment == CrossAxisAlignment.stretch, 
      'Only CrossAxisAlignment.stretch is currently supported.'),
    _crossAxisAlignment = crossAxisAlignment,
    _devicePixelRatio = devicePixelRatio;

  @override
  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsLayout();
  }

  FlexingBase get flexingBase => _flexingBase;
  FlexingBase _flexingBase;
  set flexingBase(FlexingBase value) {
    if (value == _flexingBase) return;
    _flexingBase = value;
    markNeedsLayout();
  }

  MainAxisSize get mainAxisSize => _mainAxisSize;
  MainAxisSize _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (value == _mainAxisSize) return;
    _mainAxisSize = value;
    markNeedsLayout();
  }

  MainAxisSpacing get mainAxisSpacing => _mainAxisSpacing;
  MainAxisSpacing _mainAxisSpacing;
  set mainAxisSpacing(MainAxisSpacing value) {
    if (value == _mainAxisSpacing) return;
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (value == _crossAxisAlignment) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  double? get devicePixelRatio => _devicePixelRatio;
  double? _devicePixelRatio;
  set devicePixelRatio(double? value) {
    if (value == _devicePixelRatio) return;
    _devicePixelRatio = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AutoFlexParentData)
      child.parentData = _AutoFlexParentData();
  }

  @override
  void performLayout() {
    final constraints = mainAndCrossConstraints();
    final _ChnMeasurements chnMeasurements = _takeChnMeasurements(constraints);

    final size = MainAndCrossSize();
    // A child's main intrinsic size is to be multiplied by this 
    // to get its final main size.
    double resultingPerChnIntrinsicSize;
    double flexibleSpace, emptySpace;

    if (chnMeasurements.size.main < constraints.minMain)
    {
      size.main = constraints.minMain;
      flexibleSpace = size.main - chnMeasurements.inflexibleSpace;
      switch (mainAxisSpacing) {
        case MainAxisSpacing.spaceBetween:
          resultingPerChnIntrinsicSize = 1;
          emptySpace = size.main - chnMeasurements.size.main;
          break;
        case MainAxisSpacing.fill:
          resultingPerChnIntrinsicSize = flexibleSpace / chnMeasurements.flexibleSpace;
          emptySpace = 0;
          break;
      }
    }
    else if (chnMeasurements.size.main > constraints.maxMain)
    {
      size.main = constraints.maxMain;
      flexibleSpace = size.main - chnMeasurements.inflexibleSpace;
      resultingPerChnIntrinsicSize = flexibleSpace / chnMeasurements.flexibleSpace;
      emptySpace = 0;
    }
    else
    {
      switch (mainAxisSize) {
        case MainAxisSize.min:
          size.main = chnMeasurements.size.main;
          flexibleSpace = size.main - chnMeasurements.inflexibleSpace;
          resultingPerChnIntrinsicSize = 1;
          emptySpace = 0;
          break;
        case MainAxisSize.max:
          size.main = constraints.maxMain;
          flexibleSpace = size.main - chnMeasurements.inflexibleSpace;
          switch (mainAxisSpacing) {
            case MainAxisSpacing.fill:
              resultingPerChnIntrinsicSize = flexibleSpace / chnMeasurements.flexibleSpace;
              emptySpace = 0;
              break;
            case MainAxisSpacing.spaceBetween:
              resultingPerChnIntrinsicSize = 1;
              emptySpace = size.main - chnMeasurements.size.main;
              break;
          }
          break;
      }
    }
    
    assert(flexibleSpace >= 0);
    size.cross = chnMeasurements.size.cross;
    this.size = size.sizeFor(direction);

    double offset = 0; // main axis offset
    double rawOffset = 0; // needed for snapping
    int i = 0;
    double emptySpacePerChild = emptySpace / (childCount - 1);
    visitChildren((child) {
      _AutoFlexParentData childParentData = child.parentData! as _AutoFlexParentData;
      if (childParentData.isFlexible)
        chnMeasurements.sizes[i].main *= resultingPerChnIntrinsicSize;
      if (devicePixelRatio != null) {
        rawOffset += chnMeasurements.sizes[i].main;
        double endOffset = roundDevicePixelsOfLogicalPixelsSize(
          rawOffset, devicePixelRatio: devicePixelRatio!
        );
        chnMeasurements.sizes[i].main = endOffset - offset;
      }
      Size childSize = ChildLayoutHelper.layoutChild(
        child as RenderBox, tightConstraintsFor(chnMeasurements.sizes[i]));
      childParentData.offset = offsetFor(main: offset);
      offset += mainOf(childSize) +
        (child != lastChild ? emptySpacePerChild : 0);
      i++;
    });
  }

  _ChnMeasurements _takeChnMeasurements(MainAndCrossConstraints constraints) {
    final chnMeasurements = _ChnMeasurements();

    visitChildren((renderObjectChild) {
      final child = renderObjectChild as RenderBox;
      switch (flexingBase) {
        // Assuming min main size can't be less. That is, if 
        // crossAxisAlignment is CrossAxisAlignment.stretch, main size
        // won't change and therefore can be safely found right away.
        //
        // Note that the min intinsic size for the RenderConstrainedBox with infinite 
        // constraints is the min intinsic size of its child.
        case FlexingBase.minIntrinsic:
          Size _childSize = direction == Axis.vertical ?
            getHorzIntrinsicSize(child) : getVertIntrinsicSize(child);
          chnMeasurements.sizes.add(mainAndCrossSizeFromSize(_childSize));
          break;
        case FlexingBase.maxIntrinsic:
          if (direction == Axis.vertical) {
            chnMeasurements.sizes.add(MainAndCrossSize(0, child.getMinIntrinsicWidth(double.infinity)));
          } else {
            chnMeasurements.sizes.add(MainAndCrossSize(0, child.getMinIntrinsicHeight(double.infinity)));
          }
          break;
      }
      chnMeasurements.size.cross = pickGreater(chnMeasurements.size.cross, chnMeasurements.sizes.last.cross)!;
    });

    if (chnMeasurements.size.cross < constraints.minCross)
      chnMeasurements.size.cross = constraints.minCross;
    else if (chnMeasurements.size.cross > constraints.maxCross)
      chnMeasurements.size.cross = constraints.maxCross;

    if (crossAxisAlignment == CrossAxisAlignment.stretch) {
      for (var i = 0; i < childCount; i++)
        chnMeasurements.sizes[i].cross = chnMeasurements.size.cross;
    }

    int i = 0;
    visitChildren((renderObjectChild) {
      final child = renderObjectChild as RenderBox;
      switch (flexingBase) {
        case FlexingBase.minIntrinsic:
          break;
        case FlexingBase.maxIntrinsic:
          if (direction == Axis.vertical) {
            chnMeasurements.sizes[i].main = child.getMaxIntrinsicHeight(chnMeasurements.sizes[i].cross);
          } else {
            chnMeasurements.sizes[i].main = child.getMaxIntrinsicWidth(chnMeasurements.sizes[i].cross);
          }
          break;
      }
      chnMeasurements.size.main += chnMeasurements.sizes[i].main;
      final childParentData = child.parentData as _AutoFlexParentData;
      if (childParentData.isFlexible)
        chnMeasurements.flexibleSpace += chnMeasurements.sizes[i].main;
      i++;
    });

    return chnMeasurements;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class _ChnMeasurements {
  // Children's total intrinsic size.
  final size = MainAndCrossSize();
  // Children's individual sizes.
  final List<MainAndCrossSize> sizes = [];
  double flexibleSpace = 0;
  double get inflexibleSpace => size.main - flexibleSpace;
}