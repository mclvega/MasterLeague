import 'package:intl/intl.dart';

class NumberFormatUtils {
  static final NumberFormat _thousands = NumberFormat('#,##0', 'es_ES');

  static String money(num value) {
    return _thousands.format(value);
  }
}
