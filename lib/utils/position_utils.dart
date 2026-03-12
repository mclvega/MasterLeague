class PositionUtils {
  static const Map<String, String> _aliases = {
    'EI': 'EXI',
    'EXI': 'EXI',
    'ED': 'EXD',
    'EXD': 'EXD',
    'CT': 'DEC',
    'DEC': 'DEC',
    'II': 'MDI',
    'MDI': 'MDI',
    'ID': 'MDD',
    'MDD': 'MDD',
    'MP': 'MO',
    'MO': 'MO',
  };

  static String normalize(String position) {
    final key = position.trim().toUpperCase();
    return _aliases[key] ?? key;
  }

  static bool isEquivalent(String a, String b) {
    return normalize(a) == normalize(b);
  }
}
