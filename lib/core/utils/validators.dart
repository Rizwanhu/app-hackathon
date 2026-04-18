class Validators {
  static bool isNonEmpty(String value) => value.trim().isNotEmpty;

  static bool isPhoneLike(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10;
  }
}

