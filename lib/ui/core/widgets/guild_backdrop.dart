import 'package:flutter/material.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Latar belakang bergaya Flat Minimalist Modern:
/// Kanvas gelap bersih dengan gradasi vertikal halus dan grid titik minimalis.
class GuildBackdrop extends StatelessWidget {
  final Widget child;

  const GuildBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Kanvas dasar solid obsidian
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D0F19),
                  AppTheme.darkBackground,
                  Color(0xFF0A0B13),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // 2. Minimalist subtle dot grid pattern (ringan & modern)
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _MinimalGridPainter()),
          ),
        ),

        // 3. Konten aplikasi
        child,
      ],
    );
  }
}

/// Painter grid titik minimalis dengan overhead komputasi 0 (static cache)
class _MinimalGridPainter extends CustomPainter {
  const _MinimalGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.fill;

    const step = 28.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
