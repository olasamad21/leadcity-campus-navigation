import 'dart:async';
import 'dart:math' show cos, pi;
import 'package:flutter/material.dart';
import '../theme/map_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';
import '../services/navigation_service.dart';
import '../services/location_service.dart';
import '../services/voice_navigation_controller.dart';
import '../services/voice_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

/// Navigation Screen with real-time turn-by-turn navigation
class NavigationScreen extends StatefulWidget {
  final RouteInfo routeInfo;
  final Building startBuilding;
  final Building endBuilding;

  const NavigationScreen({
    super.key,
    required this.routeInfo,
    required this.startBuilding,
    required this.endBuilding,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final LocationService _locationService = LocationService();
  final NavigationService _navigationService = NavigationService();
  final VoiceService _voiceService = VoiceService();
  late final VoiceNavigationController _voiceNavigationController;

  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  StreamSubscription<dynamic>? _locationSubscription;

  bool _hasArrived = false;

  LatLng get _destinationLatLng => widget.routeInfo.endLocation;

  @override
  void initState() {
    super.initState();
    _voiceNavigationController = VoiceNavigationController(
      widget.routeInfo.campusRoute,
      _voiceService,
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _voiceNavigationController.reset();
    _voiceService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _voiceService.initialize();
    if (!mounted) return;
    _startLocationTracking();
  }

  void _stopGpsUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Projects [rawPosition] onto the nearest point on the route polyline.
  /// If that point is farther than 25 m, returns [rawPosition] unchanged.
  LatLng _snapToRoute(LatLng rawPosition) {
    final points = widget.routeInfo.polylinePoints;
    if (points.length < 2) {
      return rawPosition;
    }

    const maxSnapMeters = 25.0;
    LatLng? bestPoint;
    var bestDistanceMeters = double.infinity;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final midLatDeg = (a.latitude + b.latitude) * 0.5;
      final k = cos(midLatDeg * pi / 180);

      final ax = a.longitude * k;
      final ay = a.latitude;
      final bx = b.longitude * k;
      final by = b.latitude;
      final px = rawPosition.longitude * k;
      final py = rawPosition.latitude;

      final dx = bx - ax;
      final dy = by - ay;
      final lenSq = dx * dx + dy * dy;

      final LatLng candidate;
      if (lenSq < 1e-18) {
        candidate = a;
      } else {
        var t = ((px - ax) * dx + (py - ay) * dy) / lenSq;
        t = t.clamp(0.0, 1.0);
        final cx = ax + t * dx;
        final cy = ay + t * dy;
        candidate = LatLng(cy, cx / k);
      }

      final d = _locationService.calculateDistance(rawPosition, candidate);
      if (d < bestDistanceMeters) {
        bestDistanceMeters = d;
        bestPoint = candidate;
      }
    }

    if (bestPoint == null || bestDistanceMeters > maxSnapMeters) {
      return rawPosition;
    }
    return bestPoint;
  }

  void _finishNavigationSession() {
    _stopGpsUpdates();
    _voiceNavigationController.reset();
  }

  void _startLocationTracking() {
    final positionStream = _locationService.getPositionStream();
    if (positionStream == null) return;

    _locationSubscription = positionStream.listen((position) {
      final latLng = _locationService.positionToLatLng(position);
      final snappedLatLng = _snapToRoute(latLng);
      _voiceNavigationController.onLocationUpdate(latLng);
      final arrived = _voiceNavigationController.checkArrival(
        latLng,
        _destinationLatLng,
      );

      setState(() {
        _currentLocation = snappedLatLng;
      });

      _updateCameraPosition();

      if (arrived && !_hasArrived && mounted) {
        _hasArrived = true;
        _stopGpsUpdates();
        _showArrivalDialog();
      }
    });
  }

  void _updateCameraPosition() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Arrived!'),
        content: Text('You have arrived at ${widget.endBuilding.name}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _finishNavigationSession();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmEndNavigation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Navigation?'),
        content: const Text('Are you sure you want to end navigation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _finishNavigationSession();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _voiceService.toggleMute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nextText = _voiceNavigationController.nextInstructionText;

    final remainingDistance = _currentLocation != null
        ? _locationService.calculateDistance(
            _currentLocation!,
            widget.routeInfo.endLocation,
          )
        : widget.routeInfo.totalDistance;

    final remainingTime = (remainingDistance / 1.4).ceil();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _confirmEndNavigation();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              style: MapStyles.of(context),
              initialCameraPosition: CameraPosition(
                target: widget.routeInfo.startLocation,
                zoom: 17,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(15.0, 18.5),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: widget.routeInfo.polylinePoints,
                  color: AppColors.primary,
                  width: 14,
                ),
              },
              markers: {
                if (_currentLocation != null)
                  Marker(
                    markerId: const MarkerId('current'),
                    position: _currentLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
                Marker(
                  markerId: const MarkerId('end'),
                  position: widget.routeInfo.endLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(title: widget.endBuilding.name),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _toggleMute,
                            icon: Icon(
                              _voiceService.isMuted
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (nextText != null)
                        Material(
                          elevation: 6,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              nextText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _navigationService
                                      .formatDistance(remainingDistance),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                      ),
                                ),
                                Text(
                                  'Remaining',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${(remainingTime / 60).ceil()} min',
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  'ETA',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _confirmEndNavigation,
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                                const Size(double.infinity, 48),
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('End Navigation'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
