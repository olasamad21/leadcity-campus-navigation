import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

/// Frosted-glass surface for controls that float over the map.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.borderRadius = AppRadius.mdAll,
    this.blur = 18,
    this.opacity,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;

  /// Fill opacity; defaults to a theme-appropriate value.
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.darkSurface : Colors.white;
    final alpha = opacity ?? (isDark ? 0.72 : 0.82);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.raised(AppColors.primaryDeep),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fill.withValues(alpha: alpha),
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small circular/rounded glass button for map overlays (back, layers, etc.).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.onSurface;
    final button = GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.smAll,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.smAll,
            onTap: onPressed,
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
