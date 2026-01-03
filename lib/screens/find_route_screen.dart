import 'package:flutter/material.dart';
import '../models/building.dart';
import '../widgets/search_field.dart';
import '../widgets/error_widget.dart';
import '../services/navigation_service.dart';
import '../services/location_service.dart';
import '../data/buildings_data.dart';
import '../theme/app_colors.dart';
import 'route_preview_screen.dart';

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
  Building? _destinationBuilding;
  bool _isCalculating = false;
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
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final latLng = _locationService.positionToLatLng(position);
      // For now, we'll use a nearby building as start
      // In a full implementation, you'd use the actual GPS coordinates
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Using current location')),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get current location')),
        );
      }
    }
  }

  Future<void> _calculateRouteIfReady() async {
    if (_startBuilding == null || _destinationBuilding == null) {
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    final route = await _navigationService.calculateRouteBetweenBuildings(
      startBuilding: _startBuilding!,
      endBuilding: _destinationBuilding!,
    );

    setState(() {
      _isCalculating = false;
      if (route != null) {
        _routeInfo = route;
      } else {
        _errorMessage = 'Unable to calculate route';
      }
    });
  }

  void _startNavigation() {
    if (_routeInfo != null && _startBuilding != null && _destinationBuilding != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutePreviewScreen(
            routeInfo: _routeInfo!,
            startBuilding: _startBuilding!,
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
                child: TextButton.icon(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _useCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

