import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/campus_graph.dart';
import '../models/building.dart';
import 'campus_routing_service.dart';

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

  /// On-campus solved route (same path as [polylinePoints] / [instructions]).
  final CampusRoute campusRoute;

  RouteInfo({
    required this.polylinePoints,
    required this.instructions,
    required this.totalDistance,
    required this.estimatedTime,
    required this.startLocation,
    required this.endLocation,
    required this.campusRoute,
  });
}

/// Campus route calculation via the on-campus graph (no Directions HTTP API).
class NavigationService {
  NavigationService._internal(this._campusRouting);

  final CampusRoutingService _campusRouting;

  static NavigationService? _instance;

  /// Singleton. Optional [campusRouting] is applied only on the first creation.
  factory NavigationService({CampusRoutingService? campusRouting}) {
    return _instance ??= NavigationService._internal(
      campusRouting ?? CampusRoutingService(campusGraph),
    );
  }

  /// Kept for compatibility with existing startup code ([app.dart]); the map
  /// SDK may still use a native key — routing no longer calls Google Directions.
  static String _apiKey = const String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Set Maps API key programmatically (routing ignores it).
  static void setApiKey(String key) {
    _apiKey = key;
  }

  static String get apiKey => _apiKey;

  /// Snaps onto the walkway graph and runs shortest-path routing.
  ///
  /// Returns `null` when there is **no graph path** between the nearest nodes
  /// to [origin] and [destination]: e.g. disconnected graph, entrances not on
  /// the network, or data gaps. Treat as an error state — **do not assume a
  /// route exists**. The UI should show a clear message such as **"Route not
  /// available"** (origin/destination not reachable via the campus graph).
  ///
  /// [mode] is ignored (previously passed to Google Directions walking mode).
  Future<RouteInfo?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'walking',
  }) async {
    final campusRoute = _campusRouting.calculateRoute(origin, destination);
    if (campusRoute == null) {
      debugPrint(
        'Campus route unavailable: no path on graph between nearest nodes '
        'to origin and destination.',
      );
      return null;
    }
    return _routeInfoFromCampusRoute(
      campusRoute,
      origin: origin,
      destination: destination,
    );
  }

  /// Calculate route between two buildings (entrance coordinates).
  Future<RouteInfo?> calculateRouteBetweenBuildings({
    required Building startBuilding,
    required Building endBuilding,
  }) async {
    return calculateRoute(
      origin: startBuilding.entrancePoint,
      destination: endBuilding.entrancePoint,
    );
  }

  RouteInfo _routeInfoFromCampusRoute(
    CampusRoute route, {
    required LatLng origin,
    required LatLng destination,
  }) {
    final turnByTurn = _turnInstructionsFromPath(route);
    final instructions = turnByTurn.isEmpty
        ? <NavigationInstruction>[
            NavigationInstruction(
              instruction:
                  'Follow the highlighted campus path toward your destination.',
              distance: route.totalDistanceMeters,
              location: destination,
            ),
          ]
        : turnByTurn;

    return RouteInfo(
      polylinePoints: route.polylinePoints,
      instructions: instructions,
      totalDistance: route.totalDistanceMeters,
      estimatedTime: route.estimatedWalkingMinutes * 60,
      startLocation: origin,
      endLocation: destination,
      campusRoute: route,
    );
  }

  /// One [NavigationInstruction] per graph edge that has a voice line, with
  /// location at the maneuver node for live navigation.
  List<NavigationInstruction> _turnInstructionsFromPath(CampusRoute route) {
    final graph = _campusRouting.graph;
    final out = <NavigationInstruction>[];
    final ids = route.nodeIds;
    for (var i = 0; i < ids.length - 1; i++) {
      final fromId = ids[i];
      final toId = ids[i + 1];
      final text = graph.getEdgeInstruction(fromId, toId);
      if (text == null) continue;
      final toNode = graph.nodes[toId];
      if (toNode == null) continue;
      out.add(
        NavigationInstruction(
          instruction: text,
          distance: graph.getEdgeDistance(fromId, toId),
          location: toNode.position,
        ),
      );
    }
    return out;
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
