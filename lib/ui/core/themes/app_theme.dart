import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFFFB300);
  static const Color accentAmber = Color(0xFFFF8F00);
  static const Color darkBackground = Color(0xFF0F1126);
  static const Color cardBackground = Color(0xFF1A1F3A);
  static const Color surfaceLighter = Color(0xFF2A2F4D);
  static const Color textMuted = Color(0xFFB8BAC8);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFD500F9);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: Colors.black,
        secondary: neonCyan,
        onSecondary: Colors.black,
        surface: cardBackground,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: surfaceLighter.withAlpha(128), width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceLighter, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLighter,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        elevation: 6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF151828),
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}
