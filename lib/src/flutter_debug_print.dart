// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'dart:core';
import 'dart:math' show min, max;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'flutter_geometry.dart';
import 'loggers.dart';
import 'render_object.dart';
import 'string_utilities.dart';
import 'geometry.dart';

int lineIndex = 0;

String prefixToMatchDigitCount(int num, int digitCount) {
  assert(digitCount > 1);
  String prefix;
  if (digitCount == 2)
    prefix = num < 10 ? '0' : '';
  else if (digitCount == 3)
    prefix = num < 100 ? num < 10 ? '00' : '0' : '';
  else if (digitCount == 4) 
    prefix = num < 1000 ? num < 100 ? num < 10 ? '000' : '00' : '0' : '';
  else prefix = 'not imlemented';
  return prefix;
}

String prefixedToMatchDigitCount(int num, int digitCount) {
  return prefixToMatchDigitCount(num, digitCount) + num.toString();
}

final List<String> _buffer = [];

void _print(Object? object, { bool buffered = false }) {
  final now = DateTime.now();
  final seconds = prefixedToMatchDigitCount(now.second, 2);
  final milliseconds = prefixedToMatchDigitCount(now.millisecond, 3);
  final line = '${prefixedToMatchDigitCount(lineIndex, 4)} $lightTextEsc[${now.minute}m:${seconds}s.${milliseconds}ms]$resetEsc $object';
  if (!buffered) print(line);
  else _buffer.add(line);
  lineIndex++;
}

void _flushBuffer() {
  for (final line in _buffer)
    print(line);
}

void _clearBuffer() {
  _buffer.clear();
}

enum LogCategory {
  none, pointer, ink
}

const actionStyleEsc = '\x1b[38;5;215m';
const actionDimStyleEsc = '\x1b[38;2;193;128;74m';
const greyTextEsc = '\x1b[38;5;8m';
const dimRedTextEsc = '\x1b[38;5;1m';
const dimGreenTextEsc = '\x1b[38;2;75;141;70m';
const resetEsc = '\x1b[0m';

String foregroundEscape(Color color) {
  return '\x1b[38;2;${color.red};${color.green};${color.blue}m';
}

String backgroundEscape(Color color) {
  return '\x1b[48;2;${color.red};${color.green};${color.blue}m';
}

final dimTextEsc = foregroundEscape(const Color(0xff2866b3));
final lightTextEsc = foregroundEscape(const Color(0xff69afff));

enum LogColor {
  grey, red, green, action, dim, unspecified
}

String escForColor(LogColor color) {
  switch (color) {
    case LogColor.red: return dimRedTextEsc;
    case LogColor.action: return actionStyleEsc;
    default: return '';
  }
}

const bool logOff = false;
const bool succinctLogMode = true;
const bool logDefault = true;
const bool logMouse = false;
const bool logInk = false;
const LogColor topLevelLogColor = LogColor.action;
const bool logStackTraces = true;

class Logger {
  static int nextDepth = 0;
  static bool buffered = false; 

  Logger(
    this.funcName, { 
    this.object, 
    this.args,
    this.category = LogCategory.none,
    this.muted = false
  }) : indent = stringFromChar(' ', 2 * nextDepth),
      nextIndent = stringFromChar(' ', 2 * (nextDepth + 1)) {
    _start();
  }

  final String funcName;
  final List<Object?>? args;
  final Object? object;
  final String indent;
  final String nextIndent;
  final LogCategory category;
  final bool muted;
  static Object? focus;

  String get argsString => args != null ? ' ' + args.toString() : '';

  bool get shouldLog {
    return 
      !logOff && !muted && 
      (focus == null || focus.runtimeType != object.runtimeType || focus == object) &&
      ((logDefault && category == LogCategory.none) ||
      (logMouse && category == LogCategory.pointer) ||
      (logInk && category == LogCategory.ink));
  }

  void focusOn(Object? object) {
    focus ??= object;
  }

  void _start() {
    if (shouldLog) {
      String objDesc = object != null ? ': $object' : '';
      String begin, end;
      begin = escForColor(topLevelLogColor);
      end = resetEsc;
      if (nextDepth == 0) _internalPrint('');
      _internalPrint('$indent$begin$funcName$argsString BGN$objDesc$end');
      nextDepth += 2;
    }
  }

  void print(Object object, [ LogColor? color ]) {
    String begin, end;
    if (color != null) {
      begin = escForColor(color);
      end = resetEsc;
    } else {
      begin = '';
      end = '';
    }

    if (shouldLog) {
      _internalPrint(begin + nextIndent + object.toString() + end);
    }
  }

  void printAction(String string, Object object, { String additional = '', bool printAncestorChain = false }) {
    String end;
    if (printAncestorChain)
         end = ' | ancestor chain: ' + widgetAncestorChainOf(object);
    else end = '';

    String objectString = object.toString();
    if (object is RenderBox)
      objectString += ' ' + rectToString(paintBounds(object));

    print(string + ' $dimGreenTextEsc' + objectString + '$resetEsc | ' + additional + end);
  }

  void printStackTrace({ int beginCount = 25, int endCount = 25 }) {
    if (shouldLog && logStackTraces) {
      String stackTrace = StackTrace.current.toString();
      stackTrace = stackTrace.replaceAll('#', '#$nextIndent');
      final lines = stackTrace.split('\n');
      if (lines.last.isEmpty) lines.removeLast();
      _internalPrint(nextIndent + '************************************************');
      var i_ = 0;
      endCount = min(endCount, lines.length);
      for (; i_ < endCount; i_++)
        _internalPrint(nextIndent + dimTextEsc + lines[i_] + resetEsc);
      if (i_ < lines.length) {
        int _i = max(i_, lines.length - beginCount);
        if (_i > i_)
          _internalPrint(nextIndent + dimTextEsc + '...' + resetEsc);
        for (; _i < lines.length; _i++)
          _internalPrint(nextIndent + dimTextEsc + lines[_i] + resetEsc);
      }
      _internalPrint(nextIndent + '************************************************');
    }
  }

  void printAncestorChainOf(Object object) {
    if (shouldLog) {
      if (object is RenderObject)
        _internalPrint(nextIndent + renderObjectAncestorChain(object, separator: '$dimGreenTextEsc ← $resetEsc'));
      else _internalPrint(nextIndent + 'printAncestorChainOf doesn\'t know type of $object');
    }
  }

  void printWidgetAncestorChainOf(Object object) {
    if (shouldLog) {
      _internalPrint(nextIndent +  widgetAncestorChainOf(object));
    }
  }

  void end([String? note]) {
    if (shouldLog) {
      if (note != null)
        note = '($note)';
      else note = '';
      String begin, end;
      begin = escForColor(topLevelLogColor);
      end = resetEsc;
      String objDesc = object != null ? ': $object' : '';
      _internalPrint('$indent$begin$funcName$argsString END$note$objDesc$end');
      nextDepth -= 2;
    }
  }

  void _internalPrint(Object object) => _print(object, buffered: buffered);
}

String widgetAncestorChainOf(Object object) {
  if (object is RenderObject)
    return renderObjectWidgetAncestorChain(object, separator: '$dimGreenTextEsc ← $resetEsc');
  else if (object is BuildContext)
    return ancestorsString(object);
  else if (object is State)
    return ancestorsString(object.context);
  else 
    return 'printAncestorChainOf doesn\'t know type of $object';
}

class BufferedLogger extends Logger {
  BufferedLogger(
    String funcName, { 
    Object? object, 
    LogCategory category = LogCategory.none,
    this.doNotFlush = false
  }) : super(
    funcName, 
    object: object,
    category: category
  ) {
    Logger.buffered = true;
  }
  
  bool doNotFlush;

  @override
  void _internalPrint(Object object) => _print(object, buffered: true);

  @override
  void end([String? note]) {
    super.end(note);
    if (shouldLog) {
      if (!doNotFlush) _flushBuffer();
      else _clearBuffer();
    }
    Logger.buffered = false;
  }
}

void printStackTrace() {
  if (!logOff && logStackTraces) {
    _print('************************************************');
    _print(StackTrace.current);
    _print('************************************************');
  }
}

void printStackTraceIfType(Object object, String type) {
  if (!logOff && logStackTraces) {
    bool shouldPrint;
    if (object.runtimeType.toString() == type ||  
      (object is Element && object.widget.runtimeType.toString() == type)) {
      shouldPrint = true;
    } else shouldPrint = false;

    if (shouldPrint) {
      _print('************************************************');
      _print(StackTrace.current);
      _print('************************************************');
    }
  }
}

bool hasAncestors(Object object, List<String> strings) {
  bool hasAncestors = true;
  for (final string in strings) {
    hasAncestors = widgetAncestorChainOf(object).contains(string);
    if (!hasAncestors) break;
  }
  return hasAncestors;
}

class OffsetLogger extends SingleChildRenderObjectWidget {
  const OffsetLogger({ 
    Key? key,
    required Widget child 
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderOffsetLogger();
}

class RenderOffsetLogger extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    String debugCreator = this.debugCreator.toString();
    int startIndex = debugCreator.indexOf('←') + 1;
    print(
      '${child.runtimeType}#$hashCode is painted at ${offsetToString(paintBounds(this).topLeft)}; ' 
      'creator: ${debugCreator.substring(startIndex).trim()}'
    );
    context.paintChild(child!, offset);
  }
}