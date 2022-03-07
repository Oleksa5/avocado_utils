
String stringFromChar(String char, [int length = 0]) {
  assert(char.length == 1);
  return String.fromCharCodes(Iterable.generate(length, (index) => char.codeUnitAt(0)));
}

String indentString(int indent) {
  return stringFromChar(' ', indent);
}

bool isCharacter(String string) {
  return string.length < 2;
}

bool isUppercaseLetter(String character) {
  assert(character.length == 1);
  final code = character.codeUnitAt(0);
  return 0x41 <= code && code <= 0x5A;
}

bool isLowercaseLetter(String character) {
  assert(character.length == 1);
  final code = character.codeUnitAt(0);
  return 0x61 <= code && code <= 0x7A;
}

bool isLetter(String character) {
  assert(character.length == 1);
  return isUppercaseLetter(character) || isLowercaseLetter(character);
}

bool isDigit(String character) {
  assert(character.length == 1);
  final code = character.codeUnitAt(0);
  return 0x30 <= code && code <= 0x39;
}