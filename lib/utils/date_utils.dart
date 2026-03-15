class AppDateUtils {
  static DateTime? parseNullableDate(dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    return DateTime.tryParse(raw);
  }

  static String? formatDate(DateTime? value) {
    if (value == null) return null;

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  static String? formatRawDate(String? raw) {
    return formatDate(parseNullableDate(raw));
  }

  static int compareNullableDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}