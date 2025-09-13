import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // Font family
  static const String fontFamily = 'SF Pro Display';
  
  // Spacing system
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  
  // Text styles
  static TextStyle get displayLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColorScheme.neutral900,
    height: 1.2,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.neutral900,
    height: 1.25,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.neutral900,
    height: 1.3,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.neutral900,
    height: 1.3,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral900,
    height: 1.3,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral900,
    height: 1.35,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.neutral900,
    height: 1.4,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral900,
    height: 1.4,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral700,
    height: 1.4,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColorScheme.neutral900,
    height: 1.5,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColorScheme.neutral900,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColorScheme.neutral700,
    height: 1.5,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral900,
    height: 1.4,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral900,
    height: 1.4,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.neutral700,
    height: 1.4,
  );

  // Shadow styles
  static List<BoxShadow> get shadowSoft => [
    BoxShadow(
      color: AppColorScheme.neutral900.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: AppColorScheme.neutral900.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowStrong => [
    BoxShadow(
      color: AppColorScheme.neutral900.withOpacity(0.16),
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Gradient styles
  static LinearGradient get castleGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColorScheme.castleGradient,
  );

  static LinearGradient get sunsetGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColorScheme.sunsetGradient,
  );

  static LinearGradient get forestGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: AppColorScheme.forestGradient,
  );

  // Complete light theme
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: AppColorScheme.lightColorScheme,
    useMaterial3: true,
    fontFamily: fontFamily,
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: headlineMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shadowColor: AppColorScheme.neutral300,
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: titleMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorScheme.primary,
        side: BorderSide(color: AppColorScheme.primary, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: titleMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: titleMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: AppColorScheme.neutral300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: spacingS),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: AppColorScheme.neutral300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: AppColorScheme.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: AppColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: AppColorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      labelStyle: bodyMedium.copyWith(color: AppColorScheme.neutral600),
      hintStyle: bodyMedium.copyWith(color: AppColorScheme.neutral500),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColorScheme.neutral200,
      thickness: 1,
      space: spacingL,
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorScheme.neutral800,
      contentTextStyle: bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Text selection theme
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColorScheme.primary,
      selectionColor: AppColorScheme.primary.withOpacity(0.3),
      selectionHandleColor: AppColorScheme.primary,
    ),
  );

  // Complete dark theme
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: AppColorScheme.darkColorScheme,
    useMaterial3: true,
    fontFamily: fontFamily,
    
    // Dark theme specific settings can be added here
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorScheme.primary700,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: headlineMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Other theme configurations can be added as needed
  );
}
