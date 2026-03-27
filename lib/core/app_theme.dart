import 'package:flutter/material.dart';

class AppTheme {
  static const palestineGreen = Color(0xFF007A3D);
  static const palestineRed = Color(0xFFCE1126);
  static const palestineBlack = Color(0xFF111111);
  static const palestineWhite = Color(0xFFFDFBF7);
  static const palestineSoft = Color(0xFFF4EFE7);
  static const palestineGold = Color(0xFFC9A227);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palestineGreen,
        brightness: Brightness.light,
      ),
    );

    final scheme = base.colorScheme.copyWith(
      primary: palestineGreen,
      onPrimary: Colors.white,
      secondary: palestineRed,
      onSecondary: Colors.white,
      tertiary: palestineGold,
      surface: palestineWhite,
      onSurface: palestineBlack,
      surfaceContainerHighest: const Color(0xFFF2ECE4),
      outline: const Color(0xFFDDD5CA),
      outlineVariant: const Color(0xFFE7DED2),
      primaryContainer: const Color(0xFFDDEFE3),
      onPrimaryContainer: palestineBlack,
      secondaryContainer: const Color(0xFFF7DADF),
      onSecondaryContainer: palestineBlack,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: palestineSoft,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palestineBlack,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: palestineBlack,
          letterSpacing: -0.8,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: palestineBlack,
          letterSpacing: -0.5,
        ),
        headlineLarge: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: palestineBlack,
        ),
        headlineMedium: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: palestineBlack,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: palestineBlack,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: palestineBlack,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: palestineBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: palestineBlack.withValues(alpha: 0.84),
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: palestineBlack,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palestineGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palestineBlack,
          side: BorderSide(
            color: palestineBlack.withValues(alpha: 0.12),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        hintStyle: TextStyle(
          color: palestineBlack.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: palestineGreen.withValues(alpha: 0.9),
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: palestineBlack.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: palestineBlack.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: palestineGreen,
            width: 1.6,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white.withValues(alpha: 0.86),
        selectedColor: palestineGreen.withValues(alpha: 0.14),
        side: BorderSide(
          color: palestineBlack.withValues(alpha: 0.08),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palestineBlack,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: palestineRed,
        foregroundColor: Colors.white,
      ),
      dividerColor: palestineBlack.withValues(alpha: 0.08),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}