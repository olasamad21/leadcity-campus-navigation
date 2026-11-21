import 'package:flutter/material.dart';

/// Building categories used for colours, icons and filters across the app.
enum BuildingCategory {
  hostel('Hostel', 'Hostels', Icons.bed_rounded, Color(0xFF2E9E6E)),
  academic('Academic', 'Academic', Icons.school_rounded, Color(0xFF4A5DB5)),
  lectureRoom('Lecture room', 'Lecture rooms', Icons.co_present_rounded,
      Color(0xFF2F8FBF)),
  food('Food', 'Food', Icons.restaurant_rounded, Color(0xFFE88B2E)),
  sports('Sports', 'Sports', Icons.sports_soccer_rounded, Color(0xFF13A39A)),
  admin('Admin', 'Admin', Icons.account_balance_rounded, Color(0xFFD9534F)),
  medical('Medical', 'Medical', Icons.local_hospital_rounded,
      Color(0xFFD94C8A)),
  religious('Religious', 'Worship', Icons.church_rounded, Color(0xFF8A5CD1)),
  facility('Facility', 'Facilities', Icons.apartment_rounded,
      Color(0xFF6C7891)),
  area('Area', 'Areas', Icons.storefront_rounded, Color(0xFFB7791F)),
  other('Other', 'Other', Icons.place_rounded, Color(0xFF7A8299));

  const BuildingCategory(this.label, this.pluralLabel, this.icon, this.color);

  /// Singular name shown on a building ("Hostel").
  final String label;

  /// Name for a filter chip or section header ("Hostels").
  final String pluralLabel;
  final IconData icon;
  final Color color;

  /// Maps a stored type string (new labels and legacy KML/fallback types)
  /// to a category.
  static BuildingCategory fromType(String type) {
    switch (type.trim().toLowerCase()) {
      case 'hostel':
      case 'residential':
        return hostel;
      case 'academic':
        return academic;
      case 'lecture room':
        return lectureRoom;
      case 'food':
      case 'dining':
      case 'recreation/dining':
        return food;
      case 'sports':
      case 'recreation':
        return sports;
      case 'admin':
      case 'administrative':
        return admin;
      case 'medical':
        return medical;
      case 'religious':
        return religious;
      case 'facility':
      case 'facilities':
        return facility;
      case 'area':
        return area;
      default:
        return other;
    }
  }
}
