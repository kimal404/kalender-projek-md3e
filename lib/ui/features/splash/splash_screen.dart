import 'package:flutter/material.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';
import 'package:quest_kalender/ui/core/widgets/guild_backdrop.dart';
import 'package:quest_kalender/ui/features/home/home_screen.dart';

/// Layar yang muncul seketika saat aplikasi dibuka, sebelum dashboard siap.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _openDashboard();
  }

  Future<void> _openDashboard() async {
    // Beri waktu frame pertama tampil, lalu biarkan dashboard selesai
    // membangun diri tanpa layar kosong.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: GuildBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.04).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGold, AppTheme.accentAmber],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withAlpha(90),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_moon,
                      size: 48,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'QUEST KALENDER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Membuka gerbang guild...',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppTheme.surfaceLighter,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
