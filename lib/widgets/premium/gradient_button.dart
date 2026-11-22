import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'pressable_scale.dart';

/// Primary call-to-action: brand gradient, colored glow, press animation,
/// and an animated swap to a spinner while [loading].
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.gradient = AppColors.brandGradient,
    this.glowColor = AppColors.primary,
    this.foreground = Colors.white,
    this.height = 56,
  });

  /// Gold variant for celebratory / highlighted actions.
  const GradientButton.accent({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.height = 56,
  })  : gradient = AppColors.accentGradient,
        glowColor = AppColors.accent,
        foreground = AppColors.primaryDeep;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Gradient gradient;
  final Color glowColor;
  final Color foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: foreground, fontSize: 16);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: PressableScale(
        onTap: enabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: AppMotion.medium,
          opacity: onPressed == null ? 0.5 : 1,
          child: AnimatedContainer(
            duration: AppMotion.medium,
            curve: AppMotion.standard,
            height: height,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: AppRadius.mdAll,
              boxShadow: enabled ? AppShadows.glow(glowColor) : const [],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              switchInCurve: AppMotion.spring,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: loading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: foreground,
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: foreground, size: 20),
                          const SizedBox(width: AppSpace.xs),
                        ],
                        Text(label, style: labelStyle),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
