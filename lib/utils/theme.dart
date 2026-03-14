import 'package:flutter/material.dart';
import 'app_links.dart';

class AppTheme {
  // Color principal azul moderno con letras blancas
  static const Color primaryColor = Color(0xFF011EA0); // Azul marca solicitado
  static const Color secondaryColor = Color(0xFF42A5F5); // Azul claro 
  static const Color accentColor = Color(0xFFFFD700); // Dorado
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  
  // URLs de imágenes remotas (fallback)
  static const String backgroundImageUrl = AppLinks.appBackgroundImage;
  static const String logoImageUrl = AppLinks.appLogoImage;

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white, // Letras blancas en primario
      onSecondary: Colors.white, // Letras blancas en secundario
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white, // Letras blancas en AppBar
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white), // Íconos blancos
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
        foregroundColor: Colors.white, // Letras blancas en botones
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 3,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor, // Botón flotante con color primario
      foregroundColor: Colors.white, // Íconos blancos en botón flotante
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

  // Position colors for players - Actualizados para el tema azul
  static const Map<String, Color> positionColors = {
    'GK': Color(0xFFFFB300), // Naranja/amarillo para porteros
    'DEF': Color(0xFF1976D2), // Azul primario para defensas
    'MID': Color(0xFF388E3C), // Verde para mediocampistas
    'FW': Color(0xFFD32F2F), // Rojo para delanteros
    'ATT': Color(0xFFD32F2F), // Rojo para atacantes
  };

  // Función para crear fondo con imagen (usa cache local si está disponible)
  static BoxDecoration get backgroundDecoration {
    return BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(backgroundImageUrl),
        fit: BoxFit.cover,
        opacity: 1.0,
      ),
    );
  }

  // Función para crear fondo con imagen más prominente
  static BoxDecoration get prominentBackgroundDecoration {
    return BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(backgroundImageUrl),
        fit: BoxFit.cover,
        opacity: 1.0,
      ),
    );
  }

  // Widget para mostrar el logo de la app
  static Widget buildAppLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.network(
      logoImageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackLogo(width, height);
      },
    );
  }

  // Logo de respaldo cuando no se puede cargar la imagen
  static Widget _buildFallbackLogo(double? width, double? height) {
    return Container(
      width: width ?? 48,
      height: height ?? 48,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: Colors.white,
        size: 32,
      ),
    );
  }

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
    } else if (pos.contains('DEF') ||
        pos.contains('CB') ||
        pos.contains('LB') ||
        pos.contains('RB') ||
        pos == 'CT' ||
        pos == 'DEC' ||
        pos == 'LI' ||
        pos == 'LD') {
      return positionColors['DEF']!;
    } else if (pos.contains('MID') ||
        pos.contains('CM') ||
        pos.contains('CDM') ||
        pos.contains('CAM') ||
        pos == 'II' ||
        pos == 'MDI' ||
        pos == 'ID' ||
        pos == 'MDD' ||
        pos == 'MP' ||
        pos == 'MO' ||
        pos == 'MC' ||
        pos == 'MCD') {
      return positionColors['MID']!;
    } else if (pos.contains('FW') ||
        pos.contains('ST') ||
        pos.contains('CF') ||
        pos.contains('LW') ||
        pos.contains('RW') ||
        pos == 'EI' ||
        pos == 'EXI' ||
        pos == 'ED' ||
        pos == 'EXD' ||
        pos == 'SD' ||
        pos == 'DC') {
      return positionColors['FW']!;
    } else {
      return Colors.grey;
    }
  }
}