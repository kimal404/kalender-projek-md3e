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

  /// Dekorasi kartu bergaya Dark Arcane Glassmorphism:
  /// Permukaan kaca kristal buram (frosted glass), gradasi specular edge tipis,
  /// dan ambient aura glow yang tembus cahaya.
  static BoxDecoration glassCardDecoration({
    Color? color,
    Color? accentColor,
    double radius = 18,
    bool isPressed = false,
    double opacity = 0.60,
  }) {
    final base = color ?? const Color(0xFF141933);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          // Pantulan kilau specular kiri-atas
          accentColor != null
              ? accentColor.withAlpha(isPressed ? 45 : 32)
              : Colors.white.withAlpha(isPressed ? 30 : 20),
          // Dasar kaca transparan
          base.withAlpha((255 * opacity).round()),
          // Sisi kanan-bawah berbayangan tipis
          Color.alphaBlend(Colors.black.withAlpha(55), base)
              .withAlpha((255 * (opacity + 0.12).clamp(0.0, 1.0)).round()),
        ],
        stops: const [0.0, 0.42, 1.0],
      ),
      border: Border.all(
        color: accentColor != null
            ? accentColor.withAlpha(isPressed ? 180 : 120)
            : Colors.white.withAlpha(isPressed ? 65 : 36),
        width: 1.2,
      ),
      boxShadow: [
        // 1. Soft diffused ambient glass shadow
        BoxShadow(
          color: Colors.black.withAlpha(isPressed ? 85 : 125),
          blurRadius: isPressed ? 10 : 22,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
        // 2. Ambient aura glow saat accentColor aktif
        if (accentColor != null)
          BoxShadow(
            color: accentColor.withAlpha(isPressed ? 35 : 24),
            blurRadius: isPressed ? 8 : 16,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
      ],
    );
  }

  /// Dekorasi tombol kaca kristal bergaya Glassmorphism
  static BoxDecoration glassButtonDecoration({
    Color primaryColor = primaryGold,
    double radius = 14,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            Colors.white.withAlpha(isPressed ? 90 : 130),
            primaryColor,
          ),
          primaryColor,
          Color.alphaBlend(Colors.black.withAlpha(35), primaryColor),
        ],
        stops: const [0.0, 0.48, 1.0],
      ),
      border: Border.all(
        color: Colors.white.withAlpha(isPressed ? 200 : 140),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withAlpha(isPressed ? 70 : 110),
          blurRadius: isPressed ? 6 : 14,
          offset: isPressed ? const Offset(0, 2) : const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withAlpha(isPressed ? 40 : 70),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  /// Dekorasi badge / pil kecil bergaya kaca buram
  static BoxDecoration glassPillDecoration({
    required Color color,
    Color? borderColor,
    double radius = 12,
    bool selected = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            Colors.white.withAlpha(selected ? 55 : 25),
            color,
          ).withAlpha(selected ? 75 : 35),
          color.withAlpha(selected ? 55 : 25),
        ],
      ),
      border: Border.all(
        color: borderColor ?? color.withAlpha(selected ? 190 : 80),
        width: selected ? 1.4 : 1.0,
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: color.withAlpha(70),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  /// Dekorasi cekung / recessed rel kaca gelap (misal: search bar, track slider)
  static BoxDecoration glassRecessedDecoration({
    double radius = 14,
    Color? color,
    Color? borderColor,
  }) {
    final base = color ?? const Color(0xFF0C0F22).withAlpha(195);
    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withAlpha(24),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(120),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.white.withAlpha(10),
          blurRadius: 2,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  /// Delegasi kompatibilitas kartu ke Glassmorphism
  static BoxDecoration clayCardDecoration({
    Color? color,
    Color? accentColor,
    double radius = 18,
    bool isPressed = false,
  }) =>
      glassCardDecoration(
        color: color,
        accentColor: accentColor,
        radius: radius,
        isPressed: isPressed,
      );

  /// Delegasi kompatibilitas tombol ke Glassmorphism
  static BoxDecoration clayButtonDecoration({
    Color primaryColor = primaryGold,
    double radius = 14,
    bool isPressed = false,
  }) =>
      glassButtonDecoration(
        primaryColor: primaryColor,
        radius: radius,
        isPressed: isPressed,
      );

  /// Delegasi kompatibilitas pil ke Glassmorphism
  static BoxDecoration clayPillDecoration({
    required Color color,
    double radius = 10,
  }) =>
      glassPillDecoration(color: color, radius: radius, selected: true);

  /// Delegasi kompatibilitas recessed ke Glassmorphism
  static BoxDecoration clayRecessedDecoration({
    double radius = 14,
    Color? color,
    Color? borderColor,
  }) =>
      glassRecessedDecoration(
        radius: radius,
        color: color,
        borderColor: borderColor,
      );

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
        backgroundColor: Colors.transparent,
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
        color: const Color(0xFF141933).withAlpha(165),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withAlpha(36), width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF131830).withAlpha(225),
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.white.withAlpha(45), width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLighter,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
