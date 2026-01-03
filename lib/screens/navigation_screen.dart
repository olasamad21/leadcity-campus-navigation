import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';
import '../services/navigation_service.dart';
import '../services/location_service.dart';
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
  
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  StreamSubscription<dynamic>? _locationSubscription;
  
  int _currentInstructionIndex = 0;
  bool _hasArrived = false;
  Timer? _voiceTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _voiceTimer?.cancel();
    _voiceService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _voiceService.initialize();
    _announceNextInstruction();
  }

  void _startLocationTracking() {
    final positionStream = _locationService.getPositionStream();
    if (positionStream != null) {
      _locationSubscription = positionStream.listen((position) {
        final latLng = _locationService.positionToLatLng(position);
        setState(() {
          _currentLocation = latLng;
        });
        _updateCameraPosition();
        _checkArrival();
        _updateCurrentInstruction();
      });
    }
  }

  void _updateCameraPosition() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  void _checkArrival() {
    if (_currentLocation == null) return;
    
    final distanceToDestination = _locationService.calculateDistance(
      _currentLocation!,
      widget.routeInfo.endLocation,
    );
    
    if (distanceToDestination < 20 && !_hasArrived) {
      setState(() {
        _hasArrived = true;
      });
      _showArrivalDialog();
    }
  }

  void _updateCurrentInstruction() {
    if (_currentLocation == null) return;
    
    // Find the closest instruction based on current location
    double minDistance = double.infinity;
    int closestIndex = 0;
    
    for (int i = 0; i < widget.routeInfo.instructions.length; i++) {
      final instruction = widget.routeInfo.instructions[i];
      final distance = _locationService.calculateDistance(
        _currentLocation!,
        instruction.location,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    
    if (closestIndex != _currentInstructionIndex) {
      setState(() {
        _currentInstructionIndex = closestIndex;
      });
      _announceNextInstruction();
    }
  }

  void _announceNextInstruction() {
    if (_currentInstructionIndex < widget.routeInfo.instructions.length) {
      final instruction = widget.routeInfo.instructions[_currentInstructionIndex];
      final distanceText = _navigationService.formatDistance(instruction.distance);
      final announcement = '$distanceText, ${instruction.instruction}';
      _voiceService.speak(announcement);
    }
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Arrived!'),
        content: Text('You have arrived at ${widget.endBuilding.name}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  void _endNavigation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Navigation?'),
        content: const Text('Are you sure you want to end navigation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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
    final currentInstruction = _currentInstructionIndex < widget.routeInfo.instructions.length
        ? widget.routeInfo.instructions[_currentInstructionIndex]
        : null;
    
    final remainingDistance = _currentLocation != null
        ? _locationService.calculateDistance(
            _currentLocation!,
            widget.routeInfo.endLocation,
          )
        : widget.routeInfo.totalDistance;
    
    final remainingTime = (remainingDistance / 1.4).ceil(); // Approximate walking speed

    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.routeInfo.startLocation,
              zoom: 17,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: widget.routeInfo.polylinePoints,
                color: AppColors.primary,
                width: 8,
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
          
          // Top Overlay - Instruction Card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mute Button
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
                    // Instruction Card
                    if (currentInstruction != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentInstruction.instruction,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _navigationService.formatDistance(currentInstruction.distance),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.primary,
                                    ),
                              ),
                              if (currentInstruction.streetName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  currentInstruction.streetName!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Overlay - Route Summary
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
                    children: [
                      // Route Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                _navigationService.formatDistance(remainingDistance),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: AppColors.primary,
                                    ),
                              ),
                              Text(
                                'Remaining',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${(remainingTime / 60).ceil()} min',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'ETA',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _endNavigation,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
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
    );
  }
}

