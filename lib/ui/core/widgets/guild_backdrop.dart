import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Latar gelap bertabur bintang dan cahaya samar, supaya layar tidak terasa kosong.
class GuildBackdrop extends StatelessWidget {
  final Widget child;

  const GuildBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1C1833),
                  AppTheme.darkBackground,
                  Color(0xFF0C0E16),
                ],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
        const Positioned.fill(child: CustomPaint(painter: _StarfieldPainter())),
        child,
      ],
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final int alpha;

  const _Star(this.x, this.y, this.radius, this.alpha);
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  static final List<_Star> _stars = List<_Star>.generate(28, (i) {
    final rng = math.Random(i * 17 + 3);
    return _Star(
      rng.nextDouble(),
      rng.nextDouble(),
      0.4 + rng.nextDouble() * 1.2,
      35 + rng.nextInt(150),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintOrb(
      canvas,
      center: Offset(size.width * 0.88, size.height * 0.06),
      radius: size.width * 0.62,
      color: AppTheme.primaryGold.withAlpha(26),
    );
    _paintOrb(
      canvas,
      center: Offset(size.width * 0.08, size.height * 0.72),
      radius: size.width * 0.5,
      color: AppTheme.neonPurple.withAlpha(22),
    );

    for (final star in _stars) {
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        Paint()..color = Colors.white.withAlpha(star.alpha),
      );
    }
  }

  void _paintOrb(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(colors: [color, Colors.transparent])
          .createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
