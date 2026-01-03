import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';

/// Navigation instruction model
class NavigationInstruction {
  final String instruction;
  final double distance; // in meters
  final LatLng location;
  final String? streetName;

  NavigationInstruction({
    required this.instruction,
    required this.distance,
    required this.location,
    this.streetName,
  });
}

/// Route information model
class RouteInfo {
  final List<LatLng> polylinePoints;
  final List<NavigationInstruction> instructions;
  final double totalDistance; // in meters
  final int estimatedTime; // in seconds
  final LatLng startLocation;
  final LatLng endLocation;

  RouteInfo({
    required this.polylinePoints,
    required this.instructions,
    required this.totalDistance,
    required this.estimatedTime,
    required this.startLocation,
    required this.endLocation,
  });
}

/// Service for route calculation and navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Google Directions API key - loaded from environment or defaults to empty
  // In production, use flutter_dotenv or similar to load from .env file
  static String _apiKey = const String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  /// Set API key programmatically (for runtime configuration)
  static void setApiKey(String key) {
    _apiKey = key;
  }
  
  /// Get current API key (for validation)
  static String get apiKey => _apiKey;

  /// Calculate route between two points
  Future<RouteInfo?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'walking',
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError('Google Maps API key not configured. Call NavigationService.setApiKey() or set GOOGLE_MAPS_API_KEY environment variable.');
    }
    
    try {
      final url = Uri.parse(
        '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=$mode'
        '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return _parseRouteResponse(data, origin, destination);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate route between two buildings
  Future<RouteInfo?> calculateRouteBetweenBuildings({
    required Building startBuilding,
    required Building endBuilding,
  }) async {
    return calculateRoute(
      origin: startBuilding.entrancePoint,
      destination: endBuilding.entrancePoint,
    );
  }

  /// Parse Google Directions API response
  RouteInfo _parseRouteResponse(
    Map<String, dynamic> data,
    LatLng origin,
    LatLng destination,
  ) {
    final route = data['routes'][0];
    final leg = route['legs'][0];
    
    // Decode polyline
    final overviewPolyline = route['overview_polyline']['points'];
    final polylinePoints = _decodePolyline(overviewPolyline);
    
    // Parse steps for instructions
    final steps = leg['steps'] as List;
    final instructions = <NavigationInstruction>[];
    
    for (var step in steps) {
      final instruction = NavigationInstruction(
        instruction: step['html_instructions']
            .toString()
            .replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
        distance: (step['distance']['value'] as int).toDouble(),
        location: LatLng(
          (step['end_location']['lat'] as num).toDouble(),
          (step['end_location']['lng'] as num).toDouble(),
        ),
        streetName: step['html_instructions']
            .toString()
            .replaceAll(RegExp(r'<[^>]*>'), ''),
      );
      instructions.add(instruction);
    }
    
    final totalDistance = (leg['distance']['value'] as int).toDouble();
    final estimatedTime = leg['duration']['value'] as int;
    
    return RouteInfo(
      polylinePoints: polylinePoints,
      instructions: instructions,
      totalDistance: totalDistance,
      estimatedTime: estimatedTime,
      startLocation: origin,
      endLocation: destination,
    );
  }

  /// Decode polyline string to list of LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final int deltaLat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final int deltaLng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Format time for display
  String formatTime(int timeInSeconds) {
    final minutes = (timeInSeconds / 60).ceil();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours h $remainingMinutes min';
    }
  }
}

