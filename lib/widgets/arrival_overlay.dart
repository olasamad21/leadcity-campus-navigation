import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/building.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'category_icon.dart';
import 'premium/gradient_button.dart';

/// Full-screen celebration shown on arrival: confetti burst, animated check,
/// destination and trip stats.
class ArrivalOverlay extends StatefulWidget {
  const ArrivalOverlay({
    super.key,
    required this.destination,
    required this.distanceLabel,
    required this.durationLabel,
    required this.onDone,
  });

  final Building destination;
  final String distanceLabel;
  final String durationLabel;
  final VoidCallback onDone;

  @override
  State<ArrivalOverlay> createState() => _ArrivalOverlayState();
}

class _ArrivalOverlayState extends State<ArrivalOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    final rnd = math.Random(7);
    const colors = [
      AppColors.accent,
      AppColors.route,
      AppColors.success,
      Color(0xFFD94C8A),
      Colors.white,
    ];
    _particles = List.generate(70, (i) {
      final angle = rnd.nextDouble() * math.pi * 2;
      return _Particle(
        angle: angle,
        speed: 220 + rnd.nextDouble() * 320,
        size: 5 + rnd.nextDouble() * 7,
        spin: (rnd.nextDouble() - 0.5) * 10,
        color: colors[i % colors.length],
        square: rnd.nextBool(),
      );
    });
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: AppColors.primaryDeep.withValues(alpha: 0.55),
          ).animate().fadeIn(duration: AppMotion.slow),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _burst,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_particles, _burst.value),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: AppRadius.lgAll,
                boxShadow: AppShadows.raised(AppColors.primaryDeep),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34C38F), AppColors.success],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.glow(AppColors.success),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 52),
                  )
                      .animate()
                      .scaleXY(
                        begin: 0,
                        end: 1,
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shimmer(duration: 900.ms),
                  const SizedBox(height: AppSpace.lg),
                  Text('You have arrived!', style: text.displayMedium)
                      .animate(delay: 200.ms)
                      .fadeIn()
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryIcon(
                          category: widget.destination.category, size: 36),
                      const SizedBox(width: AppSpace.sm),
                      Flexible(
                        child: Text(
                          widget.destination.name,
                          style: text.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpace.lg),
                  Row(
                    children: [
                      _Stat(label: 'Walked', value: widget.distanceLabel),
                      const SizedBox(width: AppSpace.sm),
                      _Stat(label: 'Time', value: widget.durationLabel),
                    ],
                  ).animate(delay: 440.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpace.lg),
                  GradientButton.accent(
                    label: 'Done',
                    icon: Icons.home_rounded,
                    onPressed: widget.onDone,
                  ).animate(delay: 560.ms).fadeIn().slideY(begin: 0.3, end: 0),
                ],
              ),
            ).animate().scaleXY(
                  begin: 0.85,
                  end: 1,
                  duration: AppMotion.slower,
                  curve: AppMotion.spring,
                ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          children: [
            Text(value, style: text.titleLarge),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
    required this.square,
  });

  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;
  final bool square;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.38);
    final ease = Curves.easeOutCubic.transform(t);
    final fade = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    for (final p in particles) {
      final travel = p.speed * ease;
      final gravity = 380 * t * t;
      final pos = origin +
          Offset(math.cos(p.angle) * travel, math.sin(p.angle) * travel + gravity);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.square) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
