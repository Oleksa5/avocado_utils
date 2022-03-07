int lastIndexOf<T>(List<T> list) {
  return list.length - 1;
}

T clamp<T extends num>(T num, T? lowerLimit, T? upperLimit) {
  assert(lowerLimit != null && upperLimit != null ? (lowerLimit <= upperLimit) : true);
  if (lowerLimit != null && num < lowerLimit) return lowerLimit;
  if (upperLimit != null && num > upperLimit) return upperLimit;
  return num;
}

List<T> mapToList<K, V, T>(Map<K, V> map, T Function(K key, V value) f) {
  List<T> list = [];
  for (final entry in map.entries)
    list.add(f(entry.key, entry.value));
  return list;
}

class Shared<T> {
  Shared(T _value) : _value = _value;
  final T _value;
  int useCount = 0;
  T get() => _value!;
}

T? as<T>(value) => value is T ? value : null;

extension ListExtenstion<T> on List<T> {
  void swap(int i0, int i1) {
    RangeError.checkValidIndex(i0, this, "i0");
    RangeError.checkValidIndex(i1, this, "i1");
    if (i0 != i1) {
      T temp0 = this[i0];
      this[i0] = this[i1];
      this[i1] = temp0; 
    }
  }

  List<E> mapIndexed<E>(E Function(T e, int i) toElement) {
    final mapped = <E>[];
    for (int i = 0; i < length; i++) {
      mapped.add(toElement(this[i], i));
    }
    return mapped;
  }
}