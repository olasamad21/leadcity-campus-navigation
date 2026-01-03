import 'package:flutter/material.dart'; // <--- ADD THIS IMPORT
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Building data model representing a campus building
class Building {
  final String id;
  final String name;
  final String type; // Academic, Administrative, Residential, etc.
  final LatLng entrancePoint; // Main entrance GPS coordinates
  final List<LatLng> polygonCoordinates; // Building footprint polygon
  final String? description;

  Building({
    required this.id,
    required this.name,
    required this.type,
    required this.entrancePoint,
    required this.polygonCoordinates,
    this.description,
  });

  /// Create a Building from JSON
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      entrancePoint: LatLng(
        (json['entrancePoint'] as Map<String, dynamic>)['latitude'] as double,
        (json['entrancePoint'] as Map<String, dynamic>)['longitude'] as double,
      ),
      polygonCoordinates: (json['polygonCoordinates'] as List)
          .map((coord) => LatLng(
                (coord as Map<String, dynamic>)['latitude'] as double,
                (coord as Map<String, dynamic>)['longitude'] as double,
              ))
          .toList(),
      description: json['description'] as String?,
    );
  }

  /// Convert Building to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'entrancePoint': {
        'latitude': entrancePoint.latitude,
        'longitude': entrancePoint.longitude,
      },
      'polygonCoordinates': polygonCoordinates
          .map((coord) => {
                'latitude': coord.latitude,
                'longitude': coord.longitude,
              })
          .toList(),
      'description': description,
    };
  }

  /// Get building polygon for Google Maps
  Polygon getPolygon({required String buildingId, required int color}) {
    return Polygon(
      polygonId: PolygonId(buildingId),
      points: polygonCoordinates,
      fillColor: Color(color),      // <--- CHANGED: Wrapped in Color()
      strokeColor: Color(color),    // <--- CHANGED: Wrapped in Color()
      strokeWidth: 2,
      geodesic: false,
    );
  }

  @override
  String toString() => 'Building(name: $name, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Building && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}