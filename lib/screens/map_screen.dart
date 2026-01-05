import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';
import '../widgets/building_details_sheet.dart';
import '../widgets/search_field.dart';
import '../data/buildings_data.dart';
import '../theme/app_colors.dart';
import 'find_route_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// FIX #1: Add AutomaticKeepAliveClientMixin
class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};

  bool _showBuildings = true;
  bool _isLoading = true;
  Building? _selectedBuilding;

  // FIX #2: Static cache to persist across screen rebuilds
  static final Map<String, BitmapDescriptor> _markerIconCache = {};
  static bool _hasGeneratedIcons = false;

  // Lead City University approximate center
  static const LatLng _campusCenter = LatLng(7.3964, 3.9167);

  @override
  // FIX #1: Required for KeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // FIX #2: Only run this heavy logic ONCE per app session
    if (!_hasGeneratedIcons) {
      _generateAllMarkers();
    } else {
      // If already generated, just load them immediately
      _loadBuildings();
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ... (Keep _getIconForBuilding exactly as it was) ...
  IconData _getIconForBuilding(Building building) {
    final name = building.name.toLowerCase();
    final type = building.type.toLowerCase();

    if (name.contains('law')) return Icons.gavel;
    if (name.contains('medical') || name.contains('clinic') || name.contains('nursing')) return Icons.medical_services;
    if (name.contains('senate')) return Icons.account_balance;
    if (name.contains('engineering')) return Icons.engineering;
    if (name.contains('computer')) return Icons.computer;
    if (name.contains('library')) return Icons.local_library;
    if (name.contains('radio')) return Icons.radio;
    if (name.contains('stadium') || name.contains('sport')) return Icons.sports_soccer;
    if (name.contains('chapel') || name.contains('mosque')) return Icons.star;

    if (type.contains('residential') || type.contains('hostel')) return Icons.bed;
    if (type.contains('dining') || type.contains('restaurant') || type.contains('cafe') || type.contains('vine')) return Icons.restaurant;
    if (type.contains('admin')) return Icons.business;

    return Icons.school;
  }

  Future<void> _generateAllMarkers() async {
    // Safety check
    if (!mounted && _hasGeneratedIcons) return;

    final buildings = BuildingsData.getAllBuildings();

    for (var building in buildings) {
      // If we are unmounted, stop working
      if (!mounted) break;

      final iconData = _getIconForBuilding(building);
      final color = AppColors.getBuildingTypeColor(building.type);
      final cacheKey = '${iconData.codePoint}_${color.value}';

      if (!_markerIconCache.containsKey(cacheKey)) {
        try {
          final bitmap = await _createCustomMarkerBitmap(iconData, color);
          if (bitmap != null) {
            _markerIconCache[cacheKey] = bitmap;
          }
          // Tiny delay to keep UI responsive
          await Future.delayed(const Duration(milliseconds: 10));
        } catch (e) {
          debugPrint("Error generating icon: $e");
        }
      }
    }

    _hasGeneratedIcons = true;

    if (mounted) {
      setState(() {
        _loadBuildings();
        _isLoading = false;
      });
    }
  }

  // ... (Keep _createCustomMarkerBitmap exactly as it was) ...
  Future<BitmapDescriptor?> _createCustomMarkerBitmap(IconData iconData, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(60, 60);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(const Offset(30, 32), 24, shadowPaint);

    final circlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(30, 30), 24, circlePaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(30, 30), 23, borderPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 28,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(30 - textPainter.width / 2, 30 - textPainter.height / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;
    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  void _loadBuildings() {
    final buildings = BuildingsData.getAllBuildings();

    _polygons.clear();
    _markers.clear();

    for (var building in buildings) {
      if (building.polygonCoordinates.length < 3) continue;

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
          consumeTapEvents: true,
          onTap: () => _showBuildingDetails(building),
        ),
      );

      final iconData = _getIconForBuilding(building);
      final cacheKey = '${iconData.codePoint}_${strokeColor.value}';

      // Use the STATIC cache here
      final iconBitmap = _markerIconCache[cacheKey];

      if (iconBitmap != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('${building.id}_marker'),
            position: _calculateCentroid(building.polygonCoordinates),
            icon: iconBitmap,
            anchor: const Offset(0.5, 0.5),
            onTap: () => _showBuildingDetails(building),
          ),
        );
      }
    }

    if (mounted) setState(() {});
  }

  // ... (Keep helper methods _calculateCentroid, _onMapTap, etc. unchanged) ...
  LatLng _calculateCentroid(List<LatLng> points) {
    if (points.isEmpty) return _campusCenter;
    double latSum = 0;
    double lngSum = 0;
    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  void _onMapTap(LatLng position) {
    for (var polygon in _polygons) {
      if (_isPointInPolygon(position, polygon.points)) {
        final building = BuildingsData.getBuildingById(polygon.polygonId.value);
        if (building != null) _showBuildingDetails(building);
        return;
      }
    }
    if (_selectedBuilding != null) setState(() => _selectedBuilding = null);
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
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
    setState(() => _selectedBuilding = building);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuildingDetailsSheet(
        building: building,
        onGetDirections: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => FindRouteScreen(initialDestination: building)));
        },
        onClose: () {
          Navigator.pop(context);
          setState(() => _selectedBuilding = null);
        },
      ),
    );
  }

  void _toggleBuildings() {
    setState(() => _showBuildings = !_showBuildings);
  }

  void _onSearch(String query) {
    final building = BuildingsData.getBuildingByName(query);
    if (building != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(building.entrancePoint));
      _showBuildingDetails(building);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX #1: Required for KeepAlive to work
    super.build(context);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _campusCenter, zoom: 17.0),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            polygons: _showBuildings ? _polygons : {},
            markers: _showBuildings ? _markers : {},
            myLocationEnabled: false, // Keeping this false for stability
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.textPrimary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: SearchField(
                        hintText: 'Search buildings...',
                        prefixIcon: Icons.search,
                        suggestions: BuildingsData.getAllBuildings().map((b) => b.name).toList(),
                        onSuggestionSelected: _onSearch,
                        showClearButton: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _toggleBuildings,
                      icon: Icon(_showBuildings ? Icons.visibility : Icons.visibility_off),
                      style: IconButton.styleFrom(backgroundColor: AppColors.background),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text("Loading Map..."),
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