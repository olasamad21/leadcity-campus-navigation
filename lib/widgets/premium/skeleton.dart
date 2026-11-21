import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

/// Shimmering placeholder block used while content loads (replaces spinners).
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.smAll,
  });

  /// Circular placeholder (avatars, icons).
  const Skeleton.circle({super.key, double size = 48})
      : width = size,
        height = size,
        borderRadius = AppRadius.pillAll;

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurfaceHigh : AppColors.surface;
    final shine = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.9);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: base, borderRadius: borderRadius),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: shine, angle: 0.4);
  }
}

/// Skeleton matching a list row (icon + two text lines).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Skeleton(width: 52, height: 52, borderRadius: AppRadius.smAll),
          SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 16),
                SizedBox(height: AppSpace.xs),
                Skeleton(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
