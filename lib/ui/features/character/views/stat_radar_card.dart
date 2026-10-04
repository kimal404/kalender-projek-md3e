import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

/// Kartu visualisasi Radar Poligon 4-Sumbu untuk menganalisis keseimbangan atribut RPG
/// karakter (STR, INT, DIS, VIT) dengan pendekatan Modern Flat Minimalist & animasi bertahap.
class StatRadarCard extends StatelessWidget {
  final UserProfile profile;

  const StatRadarCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final str = profile.strength;
    final intl = profile.intellect;
    final dis = profile.discipline;
    final vit = profile.vitality;

    final archetype = _computeArchetype(str, intl, dis, vit);
    final advice = _computeBalanceAdvice(str, intl, dis, vit);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.flatCardDecoration(
          radius: 16,
          accentColor: AppTheme.neonCyan,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header kartu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppTheme.flatPillDecoration(
                    color: AppTheme.neonCyan,
                    radius: 10,
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: AppTheme.neonCyan,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KESEIMBANGAN KARAKTER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppTheme.neonCyan,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Radar Poligon Gaya Hidup',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Proporsi pengembangan diri dan distribusi fokus harianmu.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 18),

            // Canvas Radar Poligon dengan Animasi Progresif
            Center(
              child: RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, animValue, _) {
                    return CustomPaint(
                      size: const Size(220, 200),
                      painter: _StatRadarPainter(
                        strength: str,
                        intellect: intl,
                        discipline: dis,
                        vitality: vit,
                        animationProgress: animValue,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Mini Badge Grid 4 Stat
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatChip(
                    label: 'STR',
                    value: str,
                    color: const Color(0xFFEF5350),
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMiniStatChip(
                    label: 'INT',
                    value: intl,
                    color: const Color(0xFF42A5F5),
                    icon: Icons.psychology_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMiniStatChip(
                    label: 'DIS',
                    value: dis,
                    color: const Color(0xFFAB47BC),
                    icon: Icons.task_alt_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMiniStatChip(
                    label: 'VIT',
                    value: vit,
                    color: const Color(0xFF66BB6A),
                    icon: Icons.favorite_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kartu Analisis Keseimbangan & Archetype
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.flatRecessedDecoration(
                radius: 12,
                borderColor: archetype.color.withAlpha(60),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        archetype.icon,
                        color: archetype.color,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          archetype.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: archetype.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    advice,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatChip({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: AppTheme.flatRecessedDecoration(
        radius: 8,
        borderColor: color.withAlpha(50),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$value Pts',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static _ArchetypeInfo _computeArchetype(
    int str,
    int intl,
    int dis,
    int vit,
  ) {
    final list = [
      MapEntry('STR', str),
      MapEntry('INT', intl),
      MapEntry('DIS', dis),
      MapEntry('VIT', vit),
    ];
    list.sort((a, b) => b.value.compareTo(a.value));
    final highest = list.first;
    final lowest = list.last;
    final diff = highest.value - lowest.value;

    if (diff <= 2) {
      return const _ArchetypeInfo(
        title: 'Tipe: Harmoni Seimbang (All-Rounder)',
        icon: Icons.all_inclusive_rounded,
        color: AppTheme.primaryGold,
      );
    }

    switch (highest.key) {
      case 'STR':
        return const _ArchetypeInfo(
          title: 'Tipe: Spesialis Fisik (Vanguard / Berserker)',
          icon: Icons.fitness_center_rounded,
          color: Color(0xFFEF5350),
        );
      case 'INT':
        return const _ArchetypeInfo(
          title: 'Tipe: Spesialis Intelek (Scholar / Arcanist)',
          icon: Icons.psychology_rounded,
          color: Color(0xFF42A5F5),
        );
      case 'DIS':
        return const _ArchetypeInfo(
          title: 'Tipe: Spesialis Eksekusi (Tactician / Arbiter)',
          icon: Icons.task_alt_rounded,
          color: Color(0xFFAB47BC),
        );
      case 'VIT':
      default:
        return const _ArchetypeInfo(
          title: 'Tipe: Spesialis Kebugaran (Guardian / Monk)',
          icon: Icons.favorite_rounded,
          color: Color(0xFF66BB6A),
        );
    }
  }

  static String _computeBalanceAdvice(
    int str,
    int intl,
    int dis,
    int vit,
  ) {
    final list = [
      MapEntry('Kekuatan (STR)', str),
      MapEntry('Kecerdasan (INT)', intl),
      MapEntry('Disiplin (DIS)', dis),
      MapEntry('Kebugaran (VIT)', vit),
    ];
    list.sort((a, b) => a.value.compareTo(b.value));
    final lowest = list.first;
    final highest = list.last;
    final diff = highest.value - lowest.value;

    if (diff <= 2) {
      return 'Keempat aspek produktivitasmu berkembang sangat seimbang. Pertahankan ritme hidup sehat ini!';
    }

    if (lowest.key.contains('STR')) {
      return 'Fokus fisikmu (${lowest.value} Pts) paling tertinggal. Sisipkan 15 menit peregangan atau olahraga ringan.';
    } else if (lowest.key.contains('INT')) {
      return 'Aspek intelektualmu (${lowest.value} Pts) paling tertinggal. Luangkan waktu sejenak untuk membaca buku atau belajar hal baru.';
    } else if (lowest.key.contains('DIS')) {
      return 'Rutinitas disiplinmu (${lowest.value} Pts) paling tertinggal. Jadwalkan 1 misi fokus untuk tugas penting hari ini.';
    } else {
      return 'Kebugaran & pemulihanmu (${lowest.value} Pts) paling tertinggal. Jangan lupa hidrasi air mineral dan tidur tepat waktu.';
    }
  }
}

class _ArchetypeInfo {
  final String title;
  final IconData icon;
  final Color color;

  const _ArchetypeInfo({
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// CustomPainter untuk menggambar jaring laba-laba / poligon 4-sumbu presisi tinggi
class _StatRadarPainter extends CustomPainter {
  final int strength;
  final int intellect;
  final int discipline;
  final int vitality;
  final double animationProgress;

  _StatRadarPainter({
    required this.strength,
    required this.intellect,
    required this.discipline,
    required this.vitality,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Jari-jari disesuaikan agar label sumbu di tepi tidak terpotong
    final maxRadius = math.min(cx, cy) - 22;

    // Grid Rings Konsentris (25%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const steps = [0.25, 0.50, 0.75, 1.0];
    for (final step in steps) {
      final r = maxRadius * step;
      final ringPath = Path()
        ..moveTo(cx, cy - r) // Top (STR)
        ..lineTo(cx + r, cy) // Right (INT)
        ..lineTo(cx, cy + r) // Bottom (DIS)
        ..lineTo(cx - r, cy) // Left (VIT)
        ..close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // Sumbu Silang (Cross Spokes)
    final axisPaint = Paint()
      ..color = Colors.white.withAlpha(28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(Offset(cx, cy - maxRadius), Offset(cx, cy + maxRadius), axisPaint);
    canvas.drawLine(Offset(cx - maxRadius, cy), Offset(cx + maxRadius, cy), axisPaint);

    // Titik Pusat Origin
    final originPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 2.0, originPaint);

    // Hitung Skala Maksimum (minimal skala 10 agar level awal tetap proporsional)
    final maxStat = math.max(
      math.max(strength, intellect),
      math.max(discipline, vitality),
    );
    final scaleBase = math.max(maxStat, 10).toDouble();

    final strRatio = (strength / scaleBase).clamp(0.05, 1.0);
    final intRatio = (intellect / scaleBase).clamp(0.05, 1.0);
    final disRatio = (discipline / scaleBase).clamp(0.05, 1.0);
    final vitRatio = (vitality / scaleBase).clamp(0.05, 1.0);

    // Koordinat Vertex Poligon Terinterpolasi Animasi
    final pTop = Offset(cx, cy - (maxRadius * strRatio * animationProgress));
    final pRight = Offset(cx + (maxRadius * intRatio * animationProgress), cy);
    final pBottom = Offset(cx, cy + (maxRadius * disRatio * animationProgress));
    final pLeft = Offset(cx - (maxRadius * vitRatio * animationProgress), cy);

    final polyPath = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();

    // 1. Isian Poligon (Translucent Gold / Cyan Fill)
    final fillPaint = Paint()
      ..color = AppTheme.primaryGold.withAlpha((36 * animationProgress).round())
      ..style = PaintingStyle.fill;
    canvas.drawPath(polyPath, fillPaint);

    // 2. Garis Tepi Poligon (Crisp Hairline Stroke)
    final strokePaint = Paint()
      ..color = AppTheme.primaryGold.withAlpha((220 * animationProgress).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(polyPath, strokePaint);

    // 3. Titik Sudut Vertex dengan Warna Masing-Masing Atribut
    if (animationProgress > 0.1) {
      _drawVertex(canvas, pTop, const Color(0xFFEF5350));
      _drawVertex(canvas, pRight, const Color(0xFF42A5F5));
      _drawVertex(canvas, pBottom, const Color(0xFFAB47BC));
      _drawVertex(canvas, pLeft, const Color(0xFF66BB6A));
    }

    // 4. Label Sumbu (STR, INT, DIS, VIT)
    _drawAxisLabel(canvas, 'STR', Offset(cx, cy - maxRadius - 14), const Color(0xFFEF5350));
    _drawAxisLabel(canvas, 'INT', Offset(cx + maxRadius + 14, cy), const Color(0xFF42A5F5));
    _drawAxisLabel(canvas, 'DIS', Offset(cx, cy + maxRadius + 14), const Color(0xFFAB47BC));
    _drawAxisLabel(canvas, 'VIT', Offset(cx - maxRadius - 14, cy), const Color(0xFF66BB6A));
  }

  void _drawVertex(Canvas canvas, Offset pos, Color color) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(pos, 4.0, dotPaint);
    canvas.drawCircle(pos, 4.0, borderPaint);
  }

  void _drawAxisLabel(Canvas canvas, String text, Offset centerPos, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 0.5,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      centerPos.dx - (textPainter.width / 2),
      centerPos.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _StatRadarPainter oldDelegate) {
    return oldDelegate.strength != strength ||
        oldDelegate.intellect != intellect ||
        oldDelegate.discipline != discipline ||
        oldDelegate.vitality != vitality ||
        oldDelegate.animationProgress != animationProgress;
  }
}
