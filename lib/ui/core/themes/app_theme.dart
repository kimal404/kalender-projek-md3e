import 'package:flutter/material.dart';

/// AppTheme dengan filosofi FLAT DESIGN & MODERN MINIMALIST:
/// - Permukaan warna solid & kontras terukur (clean flat surface)
/// - Garis batas presisi 1px (crisp hairline border)
/// - Menghilangkan bayangan blur berat (zero heavy shadow) untuk performa 120 FPS
/// - Tipografi tajam dengan hierarki visual yang jelas & keterbacaan tinggi
class AppTheme {
  // Palet Warna Flat Minimalist Modern
  static const Color primaryGold = Color(0xFFFFB800); // Warm Radiant Gold
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color darkBackground = Color(0xFF0C0E17); // Deep Obsidian Canvas
  static const Color cardBackground = Color(0xFF151827); // Flat Dark Slate Surface
  static const Color surfaceLighter = Color(0xFF1E2337); // Elevated Flat Surface
  static const Color surfaceSubtle = Color(0xFF10121E); // Recessed Flat Surface
  static const Color borderSubtle = Color(0xFF262B42); // Crisp Hairline 1px Border
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textSubtle = Color(0xFF64748B); // Slate 500
  static const Color neonCyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color neonPurple = Color(0xFFC084FC); // Soft Modern Violet
  static const Color accentSuccess = Color(0xFF10B981); // Emerald Green

  /// Dekorasi kartu bergaya Flat Minimalist Modern:
  /// Permukaan flat solid, border hairline presisi, tanpa blur shader berat.
  static BoxDecoration flatCardDecoration({
    Color? color,
    Color? accentColor,
    double radius = 16,
    bool isPressed = false,
    bool selected = false,
    bool hasBorder = true,
    double opacity = 1.0,
  }) {
    final base = color ?? cardBackground;
    return BoxDecoration(
      color: isPressed
          ? Color.alphaBlend(Colors.white.withAlpha(14), base)
          : (opacity < 1.0 ? base.withAlpha((255 * opacity).round()) : base),
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder
          ? Border.all(
              color: selected
                  ? (accentColor ?? primaryGold)
                  : (accentColor != null
                      ? accentColor.withAlpha(isPressed ? 190 : 100)
                      : borderSubtle),
              width: selected ? 1.5 : 1.0,
            )
          : null,
    );
  }

  /// Dekorasi tombol bergaya Flat Minimalist:
  /// Solid flat atau crisp outline, responsif terhadap animasi tekan mikro.
  static BoxDecoration flatButtonDecoration({
    Color primaryColor = primaryGold,
    double radius = 12,
    bool isPressed = false,
    bool outlined = false,
  }) {
    if (outlined) {
      return BoxDecoration(
        color: isPressed ? primaryColor.withAlpha(24) : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: primaryColor,
          width: 1.2,
        ),
      );
    }
    return BoxDecoration(
      color: isPressed
          ? Color.alphaBlend(Colors.black.withAlpha(28), primaryColor)
          : primaryColor,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Dekorasi pil / badge bergaya Flat Minimalist:
  /// Background flat tint lembut dengan garis batas kontras yang rapi.
  static BoxDecoration flatPillDecoration({
    required Color color,
    Color? borderColor,
    double radius = 10,
    bool selected = false,
  }) {
    return BoxDecoration(
      color: selected ? color.withAlpha(36) : color.withAlpha(16),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? (selected ? color : color.withAlpha(65)),
        width: selected ? 1.4 : 1.0,
      ),
    );
  }

  /// Dekorasi recessed / cekung bergaya Flat Minimalist (misal: input field, track bar)
  static BoxDecoration flatRecessedDecoration({
    double radius = 12,
    Color? color,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? surfaceSubtle,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? borderSubtle,
        width: 1.0,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Aliases untuk Kompatibilitas Transisi Penuh ke Flat Minimalist
  // ─────────────────────────────────────────────────────────────

  static BoxDecoration glassCardDecoration({
    Color? color,
    Color? accentColor,
    double radius = 16,
    bool isPressed = false,
    double opacity = 1.0,
  }) =>
      flatCardDecoration(
        color: color,
        accentColor: accentColor,
        radius: radius,
        isPressed: isPressed,
        opacity: opacity,
      );

  static BoxDecoration glassButtonDecoration({
    Color primaryColor = primaryGold,
    double radius = 12,
    bool isPressed = false,
  }) =>
      flatButtonDecoration(
        primaryColor: primaryColor,
        radius: radius,
        isPressed: isPressed,
      );

  static BoxDecoration glassPillDecoration({
    required Color color,
    Color? borderColor,
    double radius = 10,
    bool selected = false,
  }) =>
      flatPillDecoration(
        color: color,
        borderColor: borderColor,
        radius: radius,
        selected: selected,
      );

  static BoxDecoration glassRecessedDecoration({
    double radius = 12,
    Color? color,
    Color? borderColor,
  }) =>
      flatRecessedDecoration(
        radius: radius,
        color: color,
        borderColor: borderColor,
      );

  static BoxDecoration clayCardDecoration({
    Color? color,
    Color? accentColor,
    double radius = 16,
    bool isPressed = false,
  }) =>
      flatCardDecoration(
        color: color,
        accentColor: accentColor,
        radius: radius,
        isPressed: isPressed,
      );

  static BoxDecoration clayButtonDecoration({
    Color primaryColor = primaryGold,
    double radius = 12,
    bool isPressed = false,
  }) =>
      flatButtonDecoration(
        primaryColor: primaryColor,
        radius: radius,
        isPressed: isPressed,
      );

  static BoxDecoration clayPillDecoration({
    required Color color,
    double radius = 10,
  }) =>
      flatPillDecoration(color: color, radius: radius, selected: true);

  static BoxDecoration clayRecessedDecoration({
    double radius = 12,
    Color? color,
    Color? borderColor,
  }) =>
      flatRecessedDecoration(
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
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF141726),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLighter,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF111422),
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
