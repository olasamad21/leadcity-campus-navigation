import 'package:flutter/material.dart';

/// Brand + semantic color palette.
///
/// Navy primary from the Lead City crest, with a warm gold accent used
/// sparingly for highlights, progress and calls to action.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E3D77); // Deep navy
  static const Color primaryLight = Color(0xFF5A6BA3);
  static const Color primaryDark = Color(0xFF1A2554);
  static const Color primaryDeep = Color(0xFF111A3D); // Hero gradients

  static const Color accent = Color(0xFFE8B04B); // Crest gold
  static const Color accentSoft = Color(0xFFFFF1D6);

  /// Signature gradient for hero areas, primary buttons and progress.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A4C94), primary, primaryDeep],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3C46B), accent, Color(0xFFD08E22)],
  );

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22A06B);
  static const Color warning = Color(0xFFE8A23B);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF3E7BFA);

  /// Route line + live position (calm, high-contrast blue).
  static const Color route = Color(0xFF3E7BFA);
  static const Color routeWalked = Color(0xFFB8C2D6);

  // ── Neutrals (light) ─────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF6F7FB); // Scaffold behind cards
  static const Color surface = Color(0xFFF1F3F9);
  static const Color textPrimary = Color(0xFF151A2D);
  static const Color textSecondary = Color(0xFF6B7287);
  static const Color textTertiary = Color(0xFF9AA0B2);
  static const Color divider = Color(0xFFE6E9F2);

  // ── Neutrals (dark) ──────────────────────────────────────────────────────
  static const Color darkCanvas = Color(0xFF0D1122);
  static const Color darkSurface = Color(0xFF161B30);
  static const Color darkSurfaceHigh = Color(0xFF1F2540);
  static const Color darkTextPrimary = Color(0xFFF1F3FA);
  static const Color darkTextSecondary = Color(0xFFA3A9BF);
  static const Color darkDivider = Color(0xFF2A3050);

  // ── Building types (harmonised, same lightness band) ─────────────────────
  static const Color academic = Color(0xFF4A5DB5);
  static const Color administrative = Color(0xFFD9534F);
  static const Color residential = Color(0xFF2E9E6E);
  static const Color recreationDining = Color(0xFFE88B2E);
  static const Color medical = Color(0xFFD94C8A);
  static const Color religious = Color(0xFF8A5CD1);
  static const Color facilities = Color(0xFF6C7891);

  static Color getBuildingTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return academic;
      case 'administrative':
      case 'admin':
        return administrative;
      case 'residential':
        return residential;
      case 'recreation':
      case 'dining':
      case 'recreation/dining':
        return recreationDining;
      case 'medical':
        return medical;
      case 'religious':
        return religious;
      case 'facilities':
      case 'facility':
        return facilities;
      default:
        return academic;
    }
  }

  static Color getBuildingTypeColorWithOpacity(String type, double opacity) {
    return getBuildingTypeColor(type).withValues(alpha: opacity);
  }
}
