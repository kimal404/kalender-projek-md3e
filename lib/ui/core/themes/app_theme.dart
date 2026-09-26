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

  /// Dekorasi kartu bergaya Claymorphism RPG:
  /// Memadukan sudut melengkung tebal (chunky), gradien pencahayaan 3D,
  /// bayangan ganda (outer drop shadow + top ambient highlight) yang empuk/taktil.
  static BoxDecoration clayCardDecoration({
    Color? color,
    Color? accentColor,
    double radius = 18,
    bool isPressed = false,
  }) {
    final base = color ?? cardBackground;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withAlpha(22), base),
          Color.alphaBlend(Colors.black.withAlpha(35), base),
        ],
      ),
      border: Border.all(
        color: accentColor != null
            ? accentColor.withAlpha(120)
            : Colors.white.withAlpha(32),
        width: 1.5,
      ),
      boxShadow: [
        // 1. Deep grounding drop shadow (bayangan bawah gelap)
        BoxShadow(
          color: Colors.black.withAlpha(isPressed ? 90 : 140),
          blurRadius: isPressed ? 8 : 16,
          offset: isPressed ? const Offset(0, 3) : const Offset(0, 7),
          spreadRadius: -2,
        ),
        // 2. Soft top-left highlight (pantulan cahaya permukaan clay)
        BoxShadow(
          color: Colors.white.withAlpha(isPressed ? 16 : 28),
          blurRadius: 6,
          offset: const Offset(-2, -2),
          spreadRadius: 0,
        ),
        // 3. Aksen ambient glow jika diberikan
        if (accentColor != null)
          BoxShadow(
            color: accentColor.withAlpha(isPressed ? 20 : 38),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  /// Dekorasi tombol bergaya Claymorphism 3D Arcade / RPG Token
  static BoxDecoration clayButtonDecoration({
    Color primaryColor = primaryGold,
    double radius = 14,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(Colors.white.withAlpha(65), primaryColor),
          primaryColor,
        ],
      ),
      boxShadow: [
        // Deep warm drop shadow
        BoxShadow(
          color: primaryColor.withAlpha(isPressed ? 60 : 110),
          blurRadius: isPressed ? 5 : 12,
          offset: isPressed ? const Offset(0, 2) : const Offset(0, 5),
        ),
        // Top edge light highlight
        BoxShadow(
          color: Colors.white.withAlpha(140),
          blurRadius: 3,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  /// Dekorasi badge / pil kecil bergaya Claymorphism
  static BoxDecoration clayPillDecoration({
    required Color color,
    double radius = 10,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withAlpha(45), color),
          color,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withAlpha(80),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Dekorasi cekung / recessed bergaya Claymorphism (misal: search bar, track slider, info pod)
  static BoxDecoration clayRecessedDecoration({
    double radius = 14,
    Color? color,
    Color? borderColor,
  }) {
    final base = color ?? const Color(0xFF131628);
    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withAlpha(22),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(140),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.white.withAlpha(12),
          blurRadius: 2,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

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
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withAlpha(28), width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.white.withAlpha(35), width: 1.5),
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
