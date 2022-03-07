import 'dart:math' show max;

import 'package:flutter/material.dart';

const double kUnit025                 = 2;
const double kUnit05                  = 4;
const double kUnit                    = 8;
const double kUnit2                   = 16;
const double kUnit3                   = 24;
const double kPadding00625            = kPadding / 16;
const double kPadding0125             = kPadding / 8;
const double kPadding025              = kPadding / 4;
const double kPadding05               = kPadding / 2;
const double kPadding075              = kPadding05 + kPadding025;
const double kPadding                 = kUnit3;
const double kDensestPadding          = kPadding025;
const double kRadius                  = kUnit;
const double kIconSize                = 18;

const double kButtonIconSize          = kIconSize;
const double kButtonPadding           = kPadding05;
const double kButtonDimension         = kButtonIconSize + 2 * kButtonPadding;
const Size kMinButtonSize             = Size.square(kButtonDimension);
const Size kMaxButtonSize             = Size(double.infinity, double.infinity);
const double kButtonRadius            = kRadius / 2;
const double kButtonMargin            = kPadding025;
const double kDensestButtonMargin     = kPadding0125;

double barHeight([ VisualDensity visualDensity = const VisualDensity() ]) {
  return kButtonIconSize
    + 2 * max(kButtonPadding + visualDensity.baseSizeAdjustment.dy, kDensestPadding)
    + 2 * max(kButtonMargin + visualDensity.baseSizeAdjustment.dy, kDensestButtonMargin);
}

//const double kTrackHeight             = kUnit05; 
//const double kThumbOverlayRadius      = kPadding;   
const double kThumbRadius             = kPadding00625 * 5;
const double kThumbDiameter           = kThumbRadius * 2;
const double kCheckboxSize            = kThumbDiameter;
const double kRadioSize               = kThumbDiameter;

const double kListTileHorzSpacing     = kPadding;
const double kListTileVertSpacing     = kPadding05;
const kListTilePadding                = EdgeInsetsDirectional.fromSTEB(kPadding, kPadding05, kPadding, kPadding05);
final double kListTileEnlargedStarPadding = kListTilePadding.start * 2;

double listTileHeight([ VisualDensity visualDensity = const VisualDensity() ]) {
  return barHeight(visualDensity);
}

const Duration kAnimationDuration     = Duration(milliseconds: 200);

const Color kHoverOverlayColor        = Color.fromRGBO(255, 255, 255, 0.1);
const Color kFocusOverlayColor        = Color.fromRGBO(255, 255, 255, 0.2);