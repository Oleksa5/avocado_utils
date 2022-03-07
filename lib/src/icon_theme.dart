import 'package:flutter/widgets.dart';
import 'resolver.dart';

IconThemeData resolveIconThemeData(IconThemeData? first, IconThemeData? second, IconThemeData? third) 
{
  assert(second != null || third != null);
  if (first == null && second == null) return third!;
  if (first == null && third == null) return second!;

  var resolve = makeResolver(first, second, third);
  
  return IconThemeData(
    color: resolve((data) => data.color),
    opacity: resolve((data) => data.opacity),
    size: resolve((data) => data.size)
  );
}