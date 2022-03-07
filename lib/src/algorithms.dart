import 'dart:ui';

int length(TextRange range) {
  return range.end - range.start;
}

double _closestWithParity(double given, bool Function(int rounded) hasParity) {
  int rounded = given.round();
  if (!hasParity(rounded)) {
    if (rounded < given)
      return given.ceilToDouble();
    else if (given < rounded) 
      return given.floorToDouble();
    else {
      if (given > 0)
        return given - 1;
      else
        return given + 1;
    } 
  }
  return rounded.toDouble();
}

double closestOdd(double given) {
  return _closestWithParity(given, (rounded) => rounded.isOdd);
}

double closestEven(double given) {
  return _closestWithParity(given, (rounded) => rounded.isEven);
}

T? pickLess<T extends num>(T? first, T? second) {
  if (first == null) return second;
  else if (second == null) return first;
  else return first <= second ? first : second;
}

T? pickGreater<T extends num>(T? first, T? second) {
  if (first == null) return second;
  else if (second == null) return first;
  else return first >= second ? first : second;
}

bool onlyOneIsTrue3(bool a, bool b, bool c) {
  return ((a?1:0) + (b?1:0) + (c?1:0)) == 1;
}

bool atMostOneIsTrue3(bool a, bool b, bool c) {
  return !(a && b) || !(a && c) || !(b && c);
}

bool equalsAnyOf<T>(T value, List<T> list) {
  for (final T listValue in list)
    if (value == listValue)
      return true;
  return false;
}