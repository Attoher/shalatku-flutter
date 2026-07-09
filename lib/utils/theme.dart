import 'package:flutter/material.dart';

class AppTheme {
  // Default Colors (Green)
  static const Color greenPrimary = Color(0xFF1B5E20);
  static const Color greenAccent = Color(0xFFF9A825);

  // Blue Colors
  static const Color bluePrimary = Color(0xFF0D47A1);
  static const Color blueAccent = Color(0xFF00B0FF);

  // Pink Colors
  static const Color pinkPrimary = Color(0xFF880E4F);
  static const Color pinkAccent = Color(0xFFF06292);

  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;
  static const Color primary = greenPrimary; // Compatibility
  static const Color accent = greenAccent; // Compatibility
  static const Color textDark = Color(0xFF1A1A1A); // Compatibility
  static const Color textGrey = Color(0xFF757575); // Compatibility

  static ThemeData getTheme(Color primaryColor, Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardBg,
      ),
    );
  }

  static ThemeData get lightTheme => getTheme(greenPrimary, greenAccent);
  static ThemeData get blueTheme => getTheme(bluePrimary, blueAccent);
  static ThemeData get pinkTheme => getTheme(pinkPrimary, pinkAccent);
}
