import 'package:flutter/material.dart';

/// App color constants based on design system
class AppColors {
  // Primary Color: #2e3d77 (Deep Navy Blue)
  static const Color primary = Color(0xFF2E3D77);
  static const Color primaryLight = Color(0xFF5A6BA3);
  static const Color primaryDark = Color(0xFF1A2554);

  // Secondary Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Building Type Colors (for map polygons)
  static const Color academic = Color(0xFF2E3D77); // Primary
  static const Color administrative = Color(0xFFD32F2F);
  static const Color residential = Color(0xFF388E3C);
  static const Color recreationDining = Color(0xFFF57C00);
  static const Color medical = Color(0xFFC2185B);
  static const Color religious = Color(0xFF7B1FA2);
  static const Color facilities = Color(0xFF616161);

  // Helper method to get building type color
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

  // Helper method to get building type color with opacity
  static Color getBuildingTypeColorWithOpacity(String type, double opacity) {
    final color = getBuildingTypeColor(type);
    return color.withOpacity(opacity);
  }
}

