import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final String title;
  final UserProfile profile;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.title,
    required this.profile,
  });

  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required String title,
    required UserProfile profile,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          LevelUpDialog(newLevel: newLevel, title: title, profile: profile),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  // Glow pulsing badge
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  // Dialog entrance scale + fade
  late AnimationController _entranceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Confetti particles
  late AnimationController _confettiController;

  // Badge breathing
  late AnimationController _breatheController;
  late Animation<double> _breatheAnim;

  final List<_ConfettiParticle> _particles = [];
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 4.0, end: 18.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    // Confetti burst
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Badge breathe
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _breatheAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Generate particle data
    for (int i = 0; i < 20; i++) {
      _particles.add(_ConfettiParticle(rng: _rng));
    }

    // Start sequence
    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entranceController.dispose();
    _confettiController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(_scaleAnim),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Kartu Utama ──
              Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryGold.withAlpha(55),
                      AppTheme.cardBackground,
                      AppTheme.neonPurple.withAlpha(20),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withAlpha(60),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppTheme.neonPurple.withAlpha(30),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Badge dengan glow + breathe ──
                    AnimatedBuilder(
                      animation: Listenable.merge([_glowAnim, _breatheAnim]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: Tween<double>(begin: 0.92, end: 1.0).animate(_breatheAnim),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGold.withAlpha(35),
                              border: Border.all(
                                color: AppTheme.primaryGold,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withAlpha(130),
                                  blurRadius: _glowAnim.value,
                                  spreadRadius: _glowAnim.value * 0.2,
                                ),
                                BoxShadow(
                                  color: AppTheme.accentAmber.withAlpha(60),
                                  blurRadius: _glowAnim.value * 2,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.military_tech,
                              size: 56,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Teks LEVEL UP! dengan shimmer effect ──
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: const [
                          AppTheme.primaryGold,
                          AppTheme.accentAmber,
                          Color(0xFFFFE57F),
                          AppTheme.primaryGold,
                        ],
                        stops: const [0.0, 0.35, 0.65, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        '★  LEVEL UP!  ★',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Selamat! Kamu telah mencapai\nLevel ${widget.newLevel}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Gelar / Title Badge ──
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.neonCyan.withAlpha(40),
                              AppTheme.neonPurple.withAlpha(30),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.neonCyan.withAlpha(160),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonCyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Separator ──
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.surfaceLighter,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Statistik Atribut Kamu:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildAnimatedStatRow(
                      Icons.fitness_center,
                      'Kekuatan (STR)',
                      widget.profile.strength,
                      const Color(0xFFEF5350),
                      delayMs: 200,
                    ),
                    _buildAnimatedStatRow(
                      Icons.psychology,
                      'Kecerdasan (INT)',
                      widget.profile.intellect,
                      const Color(0xFF42A5F5),
                      delayMs: 320,
                    ),
                    _buildAnimatedStatRow(
                      Icons.task_alt,
                      'Disiplin (DIS)',
                      widget.profile.discipline,
                      const Color(0xFFAB47BC),
                      delayMs: 440,
                    ),
                    _buildAnimatedStatRow(
                      Icons.favorite,
                      'Kebugaran (VIT)',
                      widget.profile.vitality,
                      const Color(0xFF66BB6A),
                      delayMs: 560,
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Lanjutkan ──
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.primaryGold.withAlpha(100),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Lanjutkan Petualangan!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Confetti Particles Overlay ──
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return IgnorePointer(
                    child: SizedBox(
                      width: 360,
                      height: 400,
                      child: CustomPaint(
                        painter: _ConfettiPainter(
                          progress: _confettiController.value,
                          particles: _particles,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatRow(
    IconData icon,
    String label,
    int value,
    Color color, {
    required int delayMs,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(100)),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data model setiap partikel confetti
// ─────────────────────────────────────────────────────────────
class _ConfettiParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double startX;
  final double rotationSpeed;
  final bool isSquare;

  _ConfettiParticle({required math.Random rng})
    : angle = rng.nextDouble() * math.pi * 2,
      speed = 0.4 + rng.nextDouble() * 0.6,
      size = 4.0 + rng.nextDouble() * 6.0,
      color = _confettiColors[rng.nextInt(_confettiColors.length)],
      startX = (rng.nextDouble() - 0.5) * 280,
      rotationSpeed = (rng.nextDouble() - 0.5) * 4,
      isSquare = rng.nextBool();

  static const _confettiColors = [
    AppTheme.primaryGold,
    AppTheme.accentAmber,
    AppTheme.neonCyan,
    AppTheme.neonPurple,
    Color(0xFFFF5252),
    Color(0xFF69F0AE),
    Color(0xFFFFFFFF),
  ];
}

// ─────────────────────────────────────────────────────────────
// Custom painter untuk confetti burst
// ─────────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.25;

    for (final p in particles) {
      // Fade out in last 30% of animation
      final opacity = progress < 0.7
          ? (progress / 0.3).clamp(0.0, 1.0)
          : (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      final distance = p.speed * progress * 180;
      final gravity = 60 * progress * progress;

      final x = cx + p.startX * progress + math.cos(p.angle) * distance * 0.4;
      final y = cy - distance + gravity;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * progress * math.pi * 2);

      if (p.isSquare) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
