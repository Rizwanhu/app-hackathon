import 'package:intl/intl.dart';

extension CurrencyExtension on num {
  String toPkr({String symbol = 'PKR'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_PK',
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }
}

