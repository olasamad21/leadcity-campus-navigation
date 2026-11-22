import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/buildings_data.dart';
import '../services/places_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/page_transitions.dart';
import 'home_screen.dart';

/// Brand intro: crest scales in with a light sweep, title rises word by word,
/// then the app continues as soon as campus data is ready (min ~1.6 s).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minimumShow = Duration(milliseconds: 1600);

  @override
  void initState() {
    super.initState();
    _continueWhenReady();
  }

  Future<void> _continueWhenReady() async {
    await Future.wait([
      Future<void>.delayed(_minimumShow),
      BuildingsData.loadFromKml().catchError((_) => BuildingsData.getAllBuildings()),
      PlacesStore.instance.load(),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final words = ['Lead', 'City', 'Navigation'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Stack(
          children: [
            // Soft decorative halos.
            Positioned(
              top: -120,
              right: -80,
              child: _Halo(size: 320, color: AppColors.accent),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: _Halo(size: 360, color: AppColors.primaryLight),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scaleXY(
                        begin: 0.55,
                        end: 1,
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 400.ms)
                      .then(delay: 150.ms)
                      .shimmer(
                        duration: 900.ms,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                  const SizedBox(height: AppSpace.xl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      for (var i = 0; i < words.length; i++)
                        Text(
                          words[i],
                          style: text.displayLarge?.copyWith(
                            color: i == 2 ? AppColors.accent : Colors.white,
                          ),
                        )
                            .animate(delay: (450 + i * 110).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(
                              begin: 0.5,
                              end: 0,
                              duration: 500.ms,
                              curve: AppMotion.emphasized,
                            ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Knowledge for Self-reliance',
                    style: text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.3,
                    ),
                  ).animate(delay: 850.ms).fadeIn(duration: 500.ms),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Center(
                child: SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: AppRadius.pillAll,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppColors.accent,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.9, end: 1.1, duration: 3.seconds, curve: Curves.easeInOut);
  }
}
