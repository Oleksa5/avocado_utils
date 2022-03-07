import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'string_utilities.dart';

String makeShortcutLabel(ShortcutActivator activator) {
  assert(
    activator is SingleActivator || 
    activator is LogicalKeySet || 
    activator is CharacterActivator ||
    activator is Labeled,
    'Can\'t resolve a label based on the base type only. ' 
    'You may want to implement a ShortcutActivator with ' 
    'Labeled interface.'
  );

  final String label;
  if (activator is Labeled) 
  {
    label = (activator as Labeled).label;
  }
  else if (activator is SingleActivator) 
  {
    label = <String>[
      if (activator.control) 'Ctrl',
      if (activator.shift) 'Shift',
      if (activator.meta) 'Meta',
      if (activator.alt) 'Alt',
      activator.trigger.keyLabel,
    ].join('+');
  }
  else if (activator is LogicalKeySet) 
  {
    List<LogicalKeyboardKey> modifiers = [], keys = [];
    for (final key in activator.keys) {
      if (key.synonyms.isNotEmpty || _modifiers.contains(key))
        modifiers.add(key);
      else keys.add(key);
    }

    keys.sort((k0, k1) {
      String l0 = k0.keyLabel, l1 = k1.keyLabel;
      if (isCharacter(l0)) {
        if (!isCharacter(l1)) return -1;
        else {
          if (isLetter(l0) && !isLetter(l1)) return -1;
          else if (!isLetter(l0) && isLetter(l1)) return 1;
          else if (!isLetter(l0) && !isLetter(l1)) {
            if (isDigit(l0) && !isDigit(l1)) return -1;
            else if (!isDigit(l0) && isDigit(l1)) return 1;
          }
        }
      }
      if (!isCharacter(l0) && isCharacter(l1)) return 1;
      return l0.compareTo(l1);
    });

    final keyLabels = modifiers.map((key) {
      if (key == LogicalKeyboardKey.control) return 'Ctrl';
      if (key == LogicalKeyboardKey.shift) return 'Shift';
      if (key == LogicalKeyboardKey.meta) return 'Meta';
      if (key == LogicalKeyboardKey.alt) return 'Alt';
      return key.keyLabel;
    }).toList();

    keyLabels.addAll(keys.map((key) => key.keyLabel));

    label = keyLabels.join('+');
  }
  else if (activator is CharacterActivator) 
  {
    label = activator.character;
  }
  else 
  {
    label = '???';
  }

  return label;
}

abstract class Labeled {
  String get label;
}

final Set<LogicalKeyboardKey> _modifiers = <LogicalKeyboardKey>{
  LogicalKeyboardKey.alt,
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.meta,
  LogicalKeyboardKey.shift,
};