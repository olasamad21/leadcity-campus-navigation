import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';
import '../widgets/search_field.dart';
import '../widgets/error_widget.dart';
import '../services/navigation_service.dart';
import '../services/location_service.dart';
import '../data/buildings_data.dart';
import '../theme/app_colors.dart';
import 'route_preview_screen.dart';

/// Placeholder [Building] for preview/navigation when the route starts from live GPS.
Building _gpsOriginBuilding(LatLng latLng) {
  return Building(
    id: '__gps_current_location',
    name: 'Current Location',
    type: 'GPS',
    entrancePoint: latLng,
    polygonCoordinates: const [],
  );
}

/// Find Route Screen with start/destination selection
class FindRouteScreen extends StatefulWidget {
  final Building? initialDestination;

  const FindRouteScreen({
    super.key,
    this.initialDestination,
  });

  @override
  State<FindRouteScreen> createState() => _FindRouteScreenState();
}

class _FindRouteScreenState extends State<FindRouteScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final NavigationService _navigationService = NavigationService();
  final LocationService _locationService = LocationService();

  Building? _startBuilding;

  /// When set, "From" is live GPS ([NavigationService.calculateRoute] uses this
  /// LatLng directly; [CampusGraph.getNearestNodeId] snaps onto the graph).
  LatLng? _startGpsLatLng;

  Building? _destinationBuilding;
  bool _isCalculating = false;

  /// True while resolving GPS for "Use Current Location".
  bool _isAcquiringGps = false;

  String? _errorMessage;
  RouteInfo? _routeInfo;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      _destinationBuilding = widget.initialDestination;
      _destinationController.text = widget.initialDestination!.name;
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onStartSelected(String buildingName) {
    final building = BuildingsData.getBuildingByName(buildingName);
    if (building != null) {
      setState(() {
        _startBuilding = building;
        _startGpsLatLng = null;
        _errorMessage = null;
        _routeInfo = null;
      });
      _calculateRouteIfReady();
    }
  }

  void _onDestinationSelected(String buildingName) {
    final building = BuildingsData.getBuildingByName(buildingName);
    if (building != null) {
      setState(() {
        _destinationBuilding = building;
        _errorMessage = null;
        _routeInfo = null;
      });
      _calculateRouteIfReady();
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isAcquiringGps = true);

    final position = await _locationService.getCurrentLocation();

    if (!mounted) return;

    setState(() => _isAcquiringGps = false);

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not get your location. Please select a start point manually.',
          ),
        ),
      );
      return;
    }

    final latLng = _locationService.positionToLatLng(position);
    setState(() {
      _startGpsLatLng = latLng;
      _startBuilding = null;
      _startController.text = 'Current Location';
      _errorMessage = null;
      _routeInfo = null;
    });
    _calculateRouteIfReady();
  }

  Building? _startAsBuildingForNavigation() {
    if (_startBuilding != null) return _startBuilding;
    if (_startGpsLatLng != null) return _gpsOriginBuilding(_startGpsLatLng!);
    return null;
  }

  Future<void> _calculateRouteIfReady() async {
    if (_destinationBuilding == null) return;
    final hasStart = _startBuilding != null || _startGpsLatLng != null;
    if (!hasStart) return;

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final RouteInfo? route;
      if (_startGpsLatLng != null) {
        route = await _navigationService.calculateRoute(
          origin: _startGpsLatLng!,
          destination: _destinationBuilding!.entrancePoint,
        );
      } else {
        route = await _navigationService.calculateRouteBetweenBuildings(
          startBuilding: _startBuilding!,
          endBuilding: _destinationBuilding!,
        );
      }

      if (mounted) {
        setState(() {
          _isCalculating = false;
          if (route != null) {
            _routeInfo = route;
          } else {
            // No graph path after snapping — see NavigationService.calculateRoute.
            _errorMessage =
                'Route not available. Those locations are not connected on the campus map — try different buildings or update the walkway graph.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCalculating = false;
          _errorMessage = 'Error calculating route: ${e.toString()}';
        });
      }
    }
  }

  void _startNavigation() {
    final startNav = _startAsBuildingForNavigation();
    if (_routeInfo != null && startNav != null && _destinationBuilding != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutePreviewScreen(
            routeInfo: _routeInfo,
            startBuilding: startNav,
            endBuilding: _destinationBuilding!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingNames = BuildingsData.getAllBuildings()
        .map((b) => b.name)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Route'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start Location Section
              Text(
                'From',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SearchField(
                controller: _startController,
                hintText: 'Select start location',
                prefixIcon: Icons.location_on,
                suggestions: buildingNames,
                onSuggestionSelected: _onStartSelected,
              ),
              const SizedBox(height: 24),

              // Destination Section
              Text(
                'To',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SearchField(
                controller: _destinationController,
                hintText: 'Select destination',
                prefixIcon: Icons.place,
                suggestions: buildingNames,
                onSuggestionSelected: _onDestinationSelected,
              ),
              const SizedBox(height: 24),

              // Current Location Button
              Center(
                child: _isAcquiringGps
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      )
                    : TextButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use Current Location'),
                      ),
              ),

              // Error Message
              if (_errorMessage != null)
                RouteErrorWidget(
                  message: _errorMessage!,
                  suggestion: 'Please try different locations',
                ),

              // Route Preview Card
              if (_isCalculating)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (_routeInfo != null && !_isCalculating) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _navigationService.formatDistance(_routeInfo!.totalDistance),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_navigationService.formatTime(_routeInfo!.estimatedTime)} walk',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _startNavigation,
                          child: const Text('Start Navigation'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _isAcquiringGps
          ? FloatingActionButton(
              onPressed: null,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            )
          : FloatingActionButton(
              onPressed: _useCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
    );
  }
}