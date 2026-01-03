import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';
import '../widgets/building_details_sheet.dart';
import '../widgets/search_field.dart';
import '../data/buildings_data.dart';
import '../theme/app_colors.dart';
import 'find_route_screen.dart';

/// Interactive Map Screen with building polygons
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  bool _showBuildings = true;
  Building? _selectedBuilding;

  // Lead City University approximate center
  static const LatLng _campusCenter = LatLng(7.3964, 3.9167);

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  void _loadBuildings() {
    final buildings = BuildingsData.getAllBuildings();
    
    for (var building in buildings) {
      final color = AppColors.getBuildingTypeColorWithOpacity(
        building.type,
        0.4,
      );
      final strokeColor = AppColors.getBuildingTypeColor(building.type);
      
      _polygons.add(
        Polygon(
          polygonId: PolygonId(building.id),
          points: building.polygonCoordinates,
          fillColor: color,
          strokeColor: strokeColor,
          strokeWidth: 2,
          geodesic: false,
        ),
      );
    }
    
    setState(() {});
  }

  void _onMapTap(LatLng position) {
    // Check if tap is on a building polygon
    for (var polygon in _polygons) {
      if (_isPointInPolygon(position, polygon.points)) {
        final building = BuildingsData.getBuildingById(polygon.polygonId.value);
        if (building != null) {
          _showBuildingDetails(building);
        }
        return;
      }
    }
    
    // If not on a building, close any open bottom sheet
    if (_selectedBuilding != null) {
      setState(() {
        _selectedBuilding = null;
      });
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    // Simple point-in-polygon check (ray casting algorithm)
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude)) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _showBuildingDetails(Building building) {
    setState(() {
      _selectedBuilding = building;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuildingDetailsSheet(
        building: building,
        onGetDirections: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FindRouteScreen(
                initialDestination: building,
              ),
            ),
          );
        },
        onClose: () {
          Navigator.pop(context);
          setState(() {
            _selectedBuilding = null;
          });
        },
      ),
    );
  }

  void _toggleBuildings() {
    setState(() {
      _showBuildings = !_showBuildings;
    });
  }

  void _onSearch(String query) {
    final building = BuildingsData.getBuildingByName(query);
    if (building != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(building.entrancePoint),
      );
      _showBuildingDetails(building);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _campusCenter,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            polygons: _showBuildings ? _polygons : {},
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          
          // Top Overlay - Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        hintText: 'Search buildings...',
                        prefixIcon: Icons.search,
                        suggestions: BuildingsData.getAllBuildings()
                            .map((b) => b.name)
                            .toList(),
                        onSuggestionSelected: _onSearch,
                        showClearButton: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _toggleBuildings,
                      icon: Icon(
                        _showBuildings ? Icons.visibility : Icons.visibility_off,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

