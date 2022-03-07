import 'package:flutter/material.dart';
import 'resolver.dart';

DividerThemeData resolveDividerThemeData(DividerThemeData? first, DividerThemeData? second, DividerThemeData? third) 
{
  assert(second != null || third != null);
  if (first == null && second == null) return third!;
  if (first == null && third == null) return second!;

  final resolve = makeResolver(first, second, third);

  return DividerThemeData(
    color: resolve((style) => style.color),
    space: resolve((style) => style.space),
    thickness: resolve((style) => style.thickness),
    indent: resolve((style) => style.indent),
    endIndent: resolve((style) => style.endIndent),
  );
}