
import 'package:flutter/material.dart';

class ColorSchemeDemo extends StatelessWidget {
  const ColorSchemeDemo({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: DefaultTextStyle(
          style: textTheme.caption?.copyWith(color: colorScheme.onBackground) ?? const TextStyle(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: buildCaptions([
                  'Primary',
                  'Primary Vartiant',
                  'Secondary',
                  'Secondary Vartiant', 
                  'Surface',
                  'Background',
                  'Error'
                ])
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: buildSamples([
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.surface,
                  colorScheme.background,
                  colorScheme.error
                ])
              )
            ]
          ),
        ),
      ),
    );
  }

  List<Widget> buildSamples(List<Color> colors) {
    List<Widget> samples = [];
    for (final color in colors) {
      samples.add(buildSample(color));
    }
    return samples;
  }

  Widget buildSample(Color color) {
    return SizedBox(
      width: 100, height: 100,
      child: ColoredBox(
        color: color
      ),
    );
  }

  List<Widget> buildCaptions(List<String> strings) {
    List<Widget> captions = [];
    for (final string in strings) {
      captions.add(
        SizedBox(
          width: 100,
          child: Center(
            child: Text(string)
          ),
        )
      );
    }
    return captions;
  }
}