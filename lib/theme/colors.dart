import 'package:flutter/material.dart';

// Complete Material Design 3 Color System for Neuschwanstein Castle App
class AppColorScheme {
  // ========================================
  // PRIMARY COLOR PALETTE (Castle Blue)
  // ========================================
  static const Color primary50 = Color(0xFFE3F2FD);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary200 = Color(0xFF90CAF9);
  static const Color primary300 = Color(0xFF64B5F6);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary500 = Color(0xFF2196F3);
  static const Color primary600 = Color(0xFF1E88E5);
  static const Color primary700 = Color(0xFF1976D2);
  static const Color primary800 = Color(0xFF1565C0);
  static const Color primary900 = Color(0xFF0D47A1);
  static const Color primary = Color(0xFF1A4B84); // Main castle blue

  // ========================================
  // SECONDARY COLOR PALETTE (Accent Gold)
  // ========================================
  static const Color secondary50 = Color(0xFFFFFDE7);
  static const Color secondary100 = Color(0xFFFFF9C4);
  static const Color secondary200 = Color(0xFFFFF59D);
  static const Color secondary300 = Color(0xFFFFF176);
  static const Color secondary400 = Color(0xFFFFEE58);
  static const Color secondary500 = Color(0xFFFFEB3B);
  static const Color secondary600 = Color(0xFFFDD835);
  static const Color secondary700 = Color(0xFFFBC02D);
  static const Color secondary800 = Color(0xFFF9A825);
  static const Color secondary900 = Color(0xFFF57F17);
  static const Color secondary = Color(0xFFF2C94C); // UNESCO gold

  // ========================================
  // TERTIARY COLOR PALETTE (Light Blue)
  // ========================================
  static const Color tertiary50 = Color(0xFFE0F7FA);
  static const Color tertiary100 = Color(0xFFB2EBF2);
  static const Color tertiary200 = Color(0xFF80DEEA);
  static const Color tertiary300 = Color(0xFF4DD0E1);
  static const Color tertiary400 = Color(0xFF26C6DA);
  static const Color tertiary500 = Color(0xFF00BCD4);
  static const Color tertiary600 = Color(0xFF00ACC1);
  static const Color tertiary700 = Color(0xFF0097A7);
  static const Color tertiary800 = Color(0xFF00838F);
  static const Color tertiary900 = Color(0xFF006064);
  static const Color tertiary = Color(0xFF2E5B95); // Light castle blue

  // ========================================
  // ERROR COLOR PALETTE
  // ========================================
  static const Color error50 = Color(0xFFFFEBEE);
  static const Color error100 = Color(0xFFFFCDD2);
  static const Color error200 = Color(0xFFEF9A9A);
  static const Color error300 = Color(0xFFE57373);
  static const Color error400 = Color(0xFFEF5350);
  static const Color error500 = Color(0xFFF44336);
  static const Color error600 = Color(0xFFE53935);
  static const Color error700 = Color(0xFFD32F2F);
  static const Color error800 = Color(0xFFC62828);
  static const Color error900 = Color(0xFFB71C1C);
  static const Color error = Color(0xFFEF4444); // Main error red

  // ========================================
  // NEUTRAL COLOR PALETTE (Grays)
  // ========================================
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // ========================================
  // SUCCESS COLOR PALETTE (Green)
  // ========================================
  static const Color success50 = Color(0xFFE8F5E8);
  static const Color success100 = Color(0xFFC8E6C8);
  static const Color success200 = Color(0xFFA5D6A7);
  static const Color success300 = Color(0xFF81C784);
  static const Color success400 = Color(0xFF66BB6A);
  static const Color success500 = Color(0xFF4CAF50);
  static const Color success600 = Color(0xFF43A047);
  static const Color success700 = Color(0xFF388E3C);
  static const Color success800 = Color(0xFF2E7D32);
  static const Color success900 = Color(0xFF1B5E20);
  static const Color success = Color(0xFF10B981); // Main success green

  // ========================================
  // WARNING COLOR PALETTE (Orange)
  // ========================================
  static const Color warning50 = Color(0xFFFFF8E1);
  static const Color warning100 = Color(0xFFFFECB3);
  static const Color warning200 = Color(0xFFFFE082);
  static const Color warning300 = Color(0xFFFFD54F);
  static const Color warning400 = Color(0xFFFFCA28);
  static const Color warning500 = Color(0xFFFFC107);
  static const Color warning600 = Color(0xFFFFB300);
  static const Color warning700 = Color(0xFFFFA000);
  static const Color warning800 = Color(0xFFFF8F00);
  static const Color warning900 = Color(0xFFFF6F00);
  static const Color warning = Color(0xFFF59E0B); // Main warning orange

  // ========================================
  // INFO COLOR PALETTE (Blue)
  // ========================================
  static const Color info50 = Color(0xFFE3F2FD);
  static const Color info100 = Color(0xFFBBDEFB);
  static const Color info200 = Color(0xFF90CAF9);
  static const Color info300 = Color(0xFF64B5F6);
  static const Color info400 = Color(0xFF42A5F5);
  static const Color info500 = Color(0xFF2196F3);
  static const Color info600 = Color(0xFF1E88E5);
  static const Color info700 = Color(0xFF1976D2);
  static const Color info800 = Color(0xFF1565C0);
  static const Color info900 = Color(0xFF0D47A1);
  static const Color info = Color(0xFF3B82F6); // Main info blue

  // ========================================
  // MATERIAL DESIGN 3 COLOR SCHEME
  // ========================================
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    
    // Primary Colors (Castle Blue Theme)
    primary: primary,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDE5FF),
    onPrimaryContainer: Color(0xFF001D35),
    
    // Secondary Colors (Accent Gold)
    secondary: Color(0xFF00658B),
    onSecondary: neutral900,
    secondaryContainer: secondary100,
    onSecondaryContainer: secondary900,
    
    // Tertiary Colors (Light Blue)
    tertiary: tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFD9E2),
    onTertiaryContainer: Color(0xFF3E001D),
    
    // Error Colors
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    
    // Background and Surface
    background: neutral50,
    onBackground: neutral900,
    surface: Color(0xFFFAFDFD),
    onSurface: Color(0xFF191C1D),
    surfaceContainerHighest: Color(0xFFE1E3E3),
    onSurfaceVariant: Color(0xFF42474E),
    
    // Outline and Others
    outline: Color(0xFF72787E),
    outlineVariant: neutral200,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: neutral800,
    onInverseSurface: Color(0xFFEFF1F1),
    inversePrimary: primary200,
  );

  // ========================================
  // DARK MODE COLOR SCHEME (Future Enhancement)
  // ========================================
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    
    // Primary Colors
    primary: primary200,
    onPrimary: Color(0xFF003355),
    primaryContainer: Color(0xFF98CBFF),
    onPrimaryContainer: Color(0xFF001D35),
    
    // Secondary Colors
    secondary: Color(0xFF53D7F3),
    onSecondary: secondary900,
    secondaryContainer: secondary700,
    onSecondaryContainer: secondary100,
    
    // Tertiary Colors
    tertiary: tertiary200,
    onTertiary: tertiary900,
    tertiaryContainer: Color(0xFF7E4256),
    onTertiaryContainer: Color(0xFFFFD9E2),
    
    // Error Colors
    error: Color(0xFFFFB4AB),
    onError: error900,
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    
    // Background and Surface
    background: neutral900,
    onBackground: neutral100,
    surface: Color(0xFF191C1D),
    onSurface: Color(0xFFE1E3E3),
    surfaceContainerHighest: Color(0xFF42474E),
    onSurfaceVariant: Color(0xFFC1C7CE),
    
    // Outline and Others
    outline: Color(0xFF8B9198),
    outlineVariant: neutral700,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: neutral100,
    onInverseSurface: Color(0xFF191C1D),
    inversePrimary: primary600,
  );

  // ========================================
  // CASTLE THEME SPECIFIC COLORS
  // ========================================
  static const List<Color> castleGradient = [primary, tertiary];
  static const List<Color> sunsetGradient = [secondary500, warning500];
  static const List<Color> forestGradient = [success700, success300];
  
  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Get color by shade (50-900) for primary palette
  static Color getPrimaryShade(int shade) {
    switch (shade) {
      case 50: return primary50;
      case 100: return primary100;
      case 200: return primary200;
      case 300: return primary300;
      case 400: return primary400;
      case 500: return primary500;
      case 600: return primary600;
      case 700: return primary700;
      case 800: return primary800;
      case 900: return primary900;
      default: return primary;
    }
  }
  
  /// Get color by shade (50-900) for secondary palette
  static Color getSecondaryShade(int shade) {
    switch (shade) {
      case 50: return secondary50;
      case 100: return secondary100;
      case 200: return secondary200;
      case 300: return secondary300;
      case 400: return secondary400;
      case 500: return secondary500;
      case 600: return secondary600;
      case 700: return secondary700;
      case 800: return secondary800;
      case 900: return secondary900;
      default: return secondary;
    }
  }
  
  /// Get color by shade (50-900) for neutral palette
  static Color getNeutralShade(int shade) {
    switch (shade) {
      case 50: return neutral50;
      case 100: return neutral100;
      case 200: return neutral200;
      case 300: return neutral300;
      case 400: return neutral400;
      case 500: return neutral500;
      case 600: return neutral600;
      case 700: return neutral700;
      case 800: return neutral800;
      case 900: return neutral900;
      default: return neutral500;
    }
  }
}
