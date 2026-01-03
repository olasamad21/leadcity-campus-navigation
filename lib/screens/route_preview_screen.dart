import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import 'navigation_screen.dart';

/// Route Preview Screen showing route on map
class RoutePreviewScreen extends StatelessWidget {
  final RouteInfo routeInfo;
  final Building startBuilding;
  final Building endBuilding;

  const RoutePreviewScreen({
    super.key,
    required this.routeInfo,
    required this.startBuilding,
    required this.endBuilding,
  });

  void _startNavigation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          routeInfo: routeInfo,
          startBuilding: startBuilding,
          endBuilding: endBuilding,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    
    // Calculate camera position to show entire route
    final bounds = _calculateBounds(routeInfo.polylinePoints);
    final cameraPosition = CameraPosition(
      target: LatLng(
        (bounds['north']! + bounds['south']!) / 2,
        (bounds['east']! + bounds['west']!) / 2,
      ),
      zoom: _calculateZoom(bounds),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Preview'),
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: cameraPosition,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: routeInfo.polylinePoints,
                color: AppColors.primary,
                width: 6,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('start'),
                position: routeInfo.startLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: InfoWindow(title: startBuilding.name),
              ),
              Marker(
                markerId: const MarkerId('end'),
                position: routeInfo.endLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                infoWindow: InfoWindow(title: endBuilding.name),
              ),
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          
          // Route Info Card (bottom overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startBuilding.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            endBuilding.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                navigationService.formatDistance(routeInfo.totalDistance),
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: AppColors.primary,
                                    ),
                              ),
                              Text(
                                '${navigationService.formatTime(routeInfo.estimatedTime)}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _startNavigation(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Start Navigation'),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      // Return default bounds centered on campus if no points
      return {
        'north': 7.3970,
        'south': 7.3950,
        'east': 3.9180,
        'west': 3.9160,
      };
    }
    
    double north = points[0].latitude;
    double south = points[0].latitude;
    double east = points[0].longitude;
    double west = points[0].longitude;

    for (var point in points) {
      if (point.latitude > north) north = point.latitude;
      if (point.latitude < south) south = point.latitude;
      if (point.longitude > east) east = point.longitude;
      if (point.longitude < west) west = point.longitude;
    }

    return {'north': north, 'south': south, 'east': east, 'west': west};
  }

  double _calculateZoom(Map<String, double> bounds) {
    final latDiff = bounds['north']! - bounds['south']!;
    final lngDiff = bounds['east']! - bounds['west']!;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    if (maxDiff > 0.1) return 14.0;
    if (maxDiff > 0.05) return 15.0;
    if (maxDiff > 0.01) return 16.0;
    return 17.0;
  }
}

