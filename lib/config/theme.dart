// App theme configuration
import 'package:flutter/material.dart';

class AppTheme {
  // Paleta masculina y profesional
  static const Color primary = Color(0xFF181818); // Negro profundo
  static const Color secondary = Color(0xFF232323); // Negro alternativo
  static const Color accent = Color(0xFFFFD600); // Amarillo vibrante
  static const Color background = Color(0xFFFFFFFF); // Fondo blanco
  static const Color surface = Color(0xFFFFFFFF); // Tarjetas y superficies blancas
  static const Color error = Color(0xFFB00020);
  static const Color textPrimary = Color(0xFFFFFFFF); // Texto blanco
  static const Color textSecondary = Color(0xFFBDBDBD); // Gris claro

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: accent,
      secondary: accent,
      onSecondary: primary,
      error: error,
      onError: Colors.white,
      background: background,
      onBackground: primary,
      surface: surface,
      onSurface: primary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: accent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFD600),
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 1.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondary, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondary, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shadowColor: accent.withOpacity(0.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      shadowColor: accent.withOpacity(0.08),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: primary,
      elevation: 4,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: secondary,
    ),
    iconTheme: const IconThemeData(color: accent, size: 26),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accent),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
