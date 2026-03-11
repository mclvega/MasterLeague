import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32); // Verde fútbol
  static const Color secondaryColor = Color(0xFF4CAF50); 
  static const Color accentColor = Color(0xFFFFD700); // Dorado
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: primaryColor,
      labelStyle: const TextStyle(color: Colors.black87),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.grey,
      thickness: 1,
      space: 16,
    ),
  );

  // Custom color extensions
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Position colors for players
  static const Map<String, Color> positionColors = {
    'GK': Color(0xFFFFEB3B), // Amarillo para porteros
    'DEF': Color(0xFF2196F3), // Azul para defensas
    'MID': Color(0xFF4CAF50), // Verde para mediocampistas
    'FW': Color(0xFFE91E63), // Rojo/Rosa para delanteros
    'ATT': Color(0xFFE91E63), // Rojo/Rosa para atacantes
  };

  // Text styles
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static Color getPositionColor(String position) {
    final pos = position.toUpperCase();
    if (pos.contains('GK') || pos.contains('PORTER')) {
      return positionColors['GK']!;
    } else if (pos.contains('DEF') || pos.contains('CB') || pos.contains('LB') || pos.contains('RB')) {
      return positionColors['DEF']!;
    } else if (pos.contains('MID') || pos.contains('CM') || pos.contains('CDM') || pos.contains('CAM')) {
      return positionColors['MID']!;
    } else if (pos.contains('FW') || pos.contains('ST') || pos.contains('CF') || pos.contains('LW') || pos.contains('RW')) {
      return positionColors['FW']!;
    } else {
      return Colors.grey;
    }
  }
}