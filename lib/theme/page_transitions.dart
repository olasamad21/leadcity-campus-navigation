import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// App-wide route transition: incoming page fades in while rising slightly;
/// the outgoing page fades back and scales down a touch (shared-axis feel).
class SharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  const SharedAxisPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.slow;

  @override
  Duration get reverseTransitionDuration => AppMotion.medium;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Reusable transition so custom [PageRouteBuilder]s match the app style.
class SharedAxisTransition extends StatelessWidget {
  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.standard,
    );

    final incoming = FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: enter, curve: const Interval(0.1, 1.0)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(enter),
        child: child,
      ),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.6).animate(exit),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.96).animate(exit),
        child: incoming,
      ),
    );
  }
}

/// Convenience route using the app transition, for screens pushed in code.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: AppMotion.slow,
          reverseTransitionDuration: AppMotion.medium,
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, animation, secondary, child) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondary,
            child: child,
          ),
        );
}
