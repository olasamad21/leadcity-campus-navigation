import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_tokens.dart';

/// Shared entrance animations so every screen moves the same way.
extension AppEntrance on Widget {
  /// Fade + rise. Pass [index] to stagger items in a list or column.
  Widget fadeSlideIn({int index = 0, Duration? delay, double rise = 0.12}) {
    final d = (delay ?? Duration.zero) + AppMotion.stagger * index;
    return animate(delay: d)
        .fadeIn(duration: AppMotion.slow, curve: AppMotion.standard)
        .slideY(
          begin: rise,
          end: 0,
          duration: AppMotion.slow,
          curve: AppMotion.emphasized,
        );
  }

  /// Gentle pop for icons, badges and pins.
  Widget popIn({Duration delay = Duration.zero}) {
    return animate(delay: delay)
        .fadeIn(duration: AppMotion.medium)
        .scaleXY(
          begin: 0.6,
          end: 1,
          duration: AppMotion.slow,
          curve: AppMotion.spring,
        );
  }
}

/// Animates a number from 0 (or its previous value) to [value].
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = AppMotion.slower,
  });

  final double value;
  final String Function(double v) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: AppMotion.emphasized,
      builder: (context, v, _) => Text(format(v), style: style),
    );
  }
}
