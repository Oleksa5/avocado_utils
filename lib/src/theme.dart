import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material_lib;

import 'flutter_utilities.dart';
import 'defaults.dart';
import 'checkbox.dart';
import 'checkbox.dart' as avocado;
import 'radio.dart';
import 'radio.dart' as avocado;


ThemeData themeFromColorScheme(ColorScheme scheme) {
  return ThemeData.from(colorScheme: scheme).copyWith(
    iconTheme: const IconThemeData(size: kIconSize),
  );
}

class Theme extends StatefulWidget {
  const Theme({ 
    Key? key,
    required this.child 
  }) : super(key: key);

  final Widget child;

  @override
  State<Theme> createState() => _ThemeState();
}

class _ThemeState extends State<Theme> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = material_lib.Theme.of(context).colorScheme;

    final checkboxFillColor = MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected))
           return colorScheme.primary;
      else return null;
    }); 

    Widget result = avocado.CheckboxTheme(
      style: CheckboxStyle(
        fillColor: checkboxFillColor
      ),
      child: avocado.RadioTheme(
        style: RadioStyle(
          fillColor: checkboxFillColor
        ),
        child: widget.child
      )
    );

    if (!shouldOptimizeComponentsSizeForTouch(context)) {
      result = SliderTheme(
        data: SliderTheme.of(context).copyWith(
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: kThumbRadius)
        ),
        child: result
      );
    }

    return result;
  }
}