import 'package:flutter/widgets.dart';

class MainAndCrossSize {
  MainAndCrossSize([this.main = 0, this.cross = 0]);

  factory MainAndCrossSize.fromWH(Axis direction, double width, double height) {
    return direction == Axis.horizontal ?
      MainAndCrossSize(width, height) : MainAndCrossSize(height, width);
  }

  factory MainAndCrossSize.fromSize(Axis direction, Size size) {
    return MainAndCrossSize.fromWH(direction, size.width, size.height);
  }

  double main, cross;

  Size sizeFor(Axis direction) {
    return direction == Axis.horizontal ?
      Size(main, cross) : Size(cross, main);
  }

  BoxConstraints looseConstraintsFor(Axis direction) {
    return direction == Axis.horizontal ?
      BoxConstraints.loose(Size(main, cross)) :
      BoxConstraints.loose(Size(cross, main));
  }

  BoxConstraints tightConstraintsFor(Axis direction) {
    return direction == Axis.horizontal ?
      BoxConstraints.tightFor(width: main, height: cross) :
      BoxConstraints.tightFor(width: cross, height: main);
  }
}

class MainAndCrossConstraints {
  factory MainAndCrossConstraints(Axis direction, BoxConstraints boxConstraints) {
    return direction == Axis.horizontal ?
      MainAndCrossConstraints._(
        boxConstraints.minWidth, boxConstraints.maxWidth,
        boxConstraints.minHeight, boxConstraints.maxHeight) :
      MainAndCrossConstraints._(
        boxConstraints.minHeight, boxConstraints.maxHeight,
        boxConstraints.minWidth, boxConstraints.maxWidth);
  }

  MainAndCrossConstraints._(this.minMain, this.maxMain, this.minCross, this.maxCross);

  double minMain, maxMain, minCross, maxCross;
}

mixin Directional {
  @protected
  Axis get direction;

  @protected
  MainAndCrossSize mainAndCrossSizeFromWH(double width, double height) {
    return MainAndCrossSize.fromWH(direction, width, height);
  }

  @protected
  MainAndCrossSize mainAndCrossSizeFromSize(Size size) {
    return MainAndCrossSize.fromSize(direction, size);
  }

  @protected
  double mainOf(Size size) {
    return direction == Axis.horizontal ?
      size.width : size.height;
  }

  @protected
  double crossOf(Size size) {
    return direction == Axis.horizontal ?
      size.height : size.width;
  }

  @protected
  MainAndCrossConstraints mainAndCrossConstraintsFor(BoxConstraints boxConstraints) {
    return MainAndCrossConstraints(direction, boxConstraints);
  }

  Size sizeFor(MainAndCrossSize size) {
    return size.sizeFor(direction);
  }

  @protected
  BoxConstraints looseConstraintsFor(MainAndCrossSize size) {
    return size.looseConstraintsFor(direction);
  }

  @protected
  BoxConstraints tightConstraintsFor(MainAndCrossSize size) {
    return size.tightConstraintsFor(direction);
  }

  @protected
  Offset offsetFor({ double main = 0, double cross = 0}) {
    return direction == Axis.horizontal ?
      Offset(main, cross) : Offset(cross, main);
  }
}

mixin DirectionalRenderBox on RenderBox, Directional {
  @protected
  MainAndCrossConstraints mainAndCrossConstraints() {
    return MainAndCrossConstraints(direction, constraints);
  }
}