import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_tokens.dart';

/// Wraps any tappable surface with a tactile press: it shrinks slightly while
/// held, springs back on release, and gives a light haptic tick.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.haptics = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale while pressed (1.0 = no shrink).
  final double scale;
  final bool haptics;

  /// Clips the ink ripple to this shape when provided.
  final BorderRadius? borderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptics) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              if (widget.haptics) HapticFeedback.mediumImpact();
              widget.onLongPress!();
            },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: _pressed ? AppMotion.fast : AppMotion.medium,
        curve: _pressed ? AppMotion.standard : AppMotion.spring,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.92 : 1.0,
          duration: AppMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}
