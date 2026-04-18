class Validators {
  static bool isNonEmpty(String value) => value.trim().isNotEmpty;

  static bool isEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
  }

  static bool isPhoneLike(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10;
  }
}

