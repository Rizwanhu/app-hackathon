import 'package:intl/intl.dart';

class Formatters {
  static String compactNumber(num value) {
    final f = NumberFormat.compact(locale: 'en_PK');
    return f.format(value);
  }
}

