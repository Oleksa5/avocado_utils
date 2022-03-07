import 'package:flutter/material.dart';

class MaterialStatePropertyAll<T> implements MaterialStateProperty<T> {
  MaterialStatePropertyAll(this.value);

  static MaterialStatePropertyAll<T>? orNull<T>(T? value) {
    return value != null ? MaterialStatePropertyAll(value) : null;
  }

  final T value;

  @override
  T resolve(Set<MaterialState> states) => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is MaterialStatePropertyAll
        && other.value == value;
  }

  @override
  String toString() => 'MaterialStateProperty.all($value)';
}