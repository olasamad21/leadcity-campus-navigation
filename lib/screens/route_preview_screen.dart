import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/campus_graph.dart';
import '../models/building.dart';
import '../services/navigation_service.dart';
import 'navigation_screen.dart';

/// Route preview from on-campus graph data ([CampusRoute] via [RouteInfo]).
class RoutePreviewScreen extends StatefulWidget {
  /// When null, shows a generic “no route” message ([RouteInfo.campusRoute] is unused).
  final RouteInfo? routeInfo;
  final Building startBuilding;
  final Building endBuilding;

  const RoutePreviewScreen({
    super.key,
    required this.routeInfo,
    required this.startBuilding,
    required this.endBuilding,
  });

  @override
  State<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends State<RoutePreviewScreen> {
  final NavigationService _navigationService = NavigationService();
  GoogleMapController? _mapController;

  /// Material Blue for campus polyline / step icons per spec.
  static const MaterialColor _polylineBlue = Colors.blue;

  CampusRoute? get _campus => widget.routeInfo?.campusRoute;

  bool get _hasRoute => widget.routeInfo != null && _campus != null;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _startNavigation(BuildContext context) {
    final bundle = widget.routeInfo;
    if (bundle == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          routeInfo: bundle,
          startBuilding: widget.startBuilding,
          endBuilding: widget.endBuilding,
        ),
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    final points = _campus?.polylinePoints ?? [];
    if (points.isNotEmpty) {
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;
      for (final p in points) {
        minLat = math.min(minLat, p.latitude);
        maxLat = math.max(maxLat, p.latitude);
        minLng = math.min(minLng, p.longitude);
        maxLng = math.max(maxLng, p.longitude);
      }
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    }
  }

  /// Fits camera to [campus.polylinePoints] with 60px padding (Flutter logical pixels).
  Future<void> _fitMapToCampusPolyline(CampusRoute? campus) async {
    final controller = _mapController;
    if (controller == null || campus == null) return;

    final points = campus.polylinePoints;
    if (points.isEmpty) return;

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 17),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }

    if ((maxLat - minLat).abs() < 1e-6 &&
        (maxLng - minLng).abs() < 1e-6) {
      minLat -= 2e-4;
      maxLat += 2e-4;
      minLng -= 2e-4;
      maxLng += 2e-4;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasRoute) {
      return Scaffold(
        appBar: AppBar(title: const Text('Route Preview')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No campus route found between these locations. Please check '
              'your selection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final campus = _campus!;
    final bundle = widget.routeInfo!;

    final instructionRows = campus.instructions.isEmpty
        ? <Widget>[
            ListTile(
              leading:
                  Icon(Icons.directions_walk, color: _polylineBlue.shade700),
              title: const Text('Follow the blue path on the map.'),
            ),
          ]
        : campus.instructions.map((step) {
            return ListTile(
              leading: Icon(
                  Icons.directions_walk, color: _polylineBlue.shade700),
              title: Text(step),
            );
          }).toList();

    final distanceLabel =
        _navigationService.formatDistance(campus.totalDistanceMeters);
    final durationLabel =
        '${campus.estimatedWalkingMinutes} min';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Preview'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: campus.polylinePoints.isNotEmpty
                    ? campus.polylinePoints.first
                    : LatLng(
                        widget.startBuilding.entrancePoint.latitude,
                        widget.startBuilding.entrancePoint.longitude,
                      ),
                zoom: 17,
              ),
              onMapCreated: _onMapCreated,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('campus_route'),
                  points: campus.polylinePoints,
                  color: _polylineBlue.shade700,
                  width: 14,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('start'),
                  position: bundle.startLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(title: widget.startBuilding.name),
                ),
                Marker(
                  markerId: const MarkerId('end'),
                  position: bundle.endLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(title: widget.endBuilding.name),
                ),
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  distanceLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  durationLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              itemCount: instructionRows.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => instructionRows[index],
            ),
          ),
          SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startNavigation(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Start navigation'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
