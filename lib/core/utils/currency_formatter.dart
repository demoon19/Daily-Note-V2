import 'package:intl/intl.dart';

/// Format nominal Rupiah dipakai di fitur expense & summary.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num amount) => _rupiahFormat.format(amount);

  /// Parsing input user (mis. dari text field "100000" atau "100.000")
  /// menjadi double, dipakai saat mem-parsing intent expense.
  static double? parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}