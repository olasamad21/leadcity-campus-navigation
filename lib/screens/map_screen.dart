import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/buildings_data.dart';
import '../models/building.dart';
import '../models/building_category.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/map_styles.dart';
import '../utils/map_markers.dart';
import '../widgets/category_icon.dart';
import '../widgets/premium/glass_panel.dart';
import '../widgets/premium/gradient_button.dart';
import '../widgets/premium/motion.dart';
import '../widgets/premium/pressable_scale.dart';
import 'building_search_screen.dart';
import 'find_route_screen.dart';

/// Interactive campus map: category filters, glass controls, tap a building
/// to see a floating card with directions.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.focusBuilding});

  /// Building to centre on and select when the map opens.
  final Building? focusBuilding;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  late final List<Building> _buildings;
  late final LatLngBounds _campusBounds;

  BuildingCategory? _filter;
  Building? _selected;
  bool _markersReady = false;
  bool _locating = false;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _buildings = List.of(BuildingsData.getAllBuildings());
    _campusBounds = _boundsOf(_allPoints);
    _selected = widget.focusBuilding;
    MapMarkers.warmUp().then((_) {
      if (mounted) setState(() => _markersReady = true);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── geometry helpers ───────────────────────────────────────────────────

  static LatLngBounds _boundsOf(
    Iterable<LatLng> points, {
    double pad = 0.0015,
  }) {
    var minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    if (minLat > maxLat) {
      const c = BuildingsData.campusCenter;
      return LatLngBounds(
        southwest: LatLng(c.latitude - pad, c.longitude - pad),
        northeast: LatLng(c.latitude + pad, c.longitude + pad),
      );
    }
    return LatLngBounds(
      southwest: LatLng(minLat - pad, minLng - pad),
      northeast: LatLng(maxLat + pad, maxLng + pad),
    );
  }

  /// Every outline vertex plus the pin of point-only places.
  Iterable<LatLng> get _allPoints => _buildings.expand(
    (b) => b.polygonCoordinates.length >= 3
        ? b.polygonCoordinates
        : [b.entrancePoint],
  );

  /// Where a building's marker sits: outline centre, or the point itself.
  static LatLng _anchorOf(Building b) => b.polygonCoordinates.length >= 3
      ? _centroid(b.polygonCoordinates)
      : b.entrancePoint;

  static LatLng _centroid(List<LatLng> pts) {
    var lat = 0.0, lng = 0.0;
    for (final p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / pts.length, lng / pts.length);
  }

  LatLng get _campusCentre => LatLng(
    (_campusBounds.southwest.latitude + _campusBounds.northeast.latitude) / 2,
    (_campusBounds.southwest.longitude + _campusBounds.northeast.longitude) / 2,
  );

  // ── actions ────────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final focus = widget.focusBuilding;
    if (focus != null) {
      Future.delayed(const Duration(milliseconds: 300), () => _focus(focus));
    }
  }

  void _select(Building b) {
    HapticFeedback.selectionClick();
    setState(() => _selected = b);
    _focus(b);
  }

  void _focus(Building b) {
    final target = _anchorOf(b);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 18, tilt: 30),
      ),
    );
  }

  Future<void> _openSearch() async {
    final picked = await Navigator.of(context).push<Building>(
      MaterialPageRoute(builder: (_) => const BuildingSearchScreen()),
    );
    if (picked == null || !mounted) return;
    if (_filter != null && picked.category != _filter) {
      setState(() => _filter = null);
    }
    _select(picked);
  }

  Future<void> _locateMe() async {
    setState(() => _locating = true);
    final pos = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location.')),
      );
      return;
    }
    final here = _locationService.positionToLatLng(pos);
    setState(() => _userLocation = here);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(here, 18));
  }

  void _recentre() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(_boundsOf(_allPoints, pad: 0.0002), 40),
    );
  }

  void _directions(Building b) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FindRouteScreen(initialDestination: b)),
    );
  }

  // ── map layers ─────────────────────────────────────────────────────────

  Iterable<Building> get _visible => _filter == null
      ? _buildings
      : _buildings.where((b) => b.category == _filter);

  Set<Polygon> _polygons() {
    return {
      for (final b in _visible)
        if (b.polygonCoordinates.length >= 3)
          Polygon(
            polygonId: PolygonId(b.id),
            points: b.polygonCoordinates,
            fillColor: b.category.color.withValues(
              alpha: b == _selected ? 0.55 : 0.28,
            ),
            strokeColor: b.category.color,
            strokeWidth: b == _selected ? 3 : 1,
            zIndex: b == _selected ? 2 : 1,
            consumeTapEvents: true,
            onTap: () => _select(b),
          ),
    };
  }

  Set<Marker> _markers() {
    final out = <Marker>{};
    if (_markersReady) {
      for (final b in _visible) {
        final selected = b == _selected;
        final icon = MapMarkers.cached(b.category, selected: selected);
        if (icon == null) continue;
        out.add(
          Marker(
            markerId: MarkerId('m_${b.id}'),
            position: _anchorOf(b),
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            zIndexInt: selected ? 3 : 1,
            onTap: () => _select(b),
          ),
        );
      }
    }
    final user = _userLocation;
    final dot = MapMarkers.cachedUserDot;
    if (user != null && dot != null) {
      out.add(
        Marker(
          markerId: const MarkerId('me'),
          position: user,
          icon: dot,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          zIndexInt: 5,
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final categories = BuildingCategory.values
        .where((c) => _buildings.any((b) => b.category == c))
        .toList();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              style: MapStyles.of(context),
              initialCameraPosition: CameraPosition(
                target: _campusCentre,
                zoom: 16.4,
              ),
              cameraTargetBounds: CameraTargetBounds(_campusBounds),
              minMaxZoomPreference: const MinMaxZoomPreference(15.5, 20),
              onMapCreated: _onMapCreated,
              onTap: (_) {
                if (_selected != null) setState(() => _selected = null);
              },
              polygons: _polygons(),
              markers: _markers(),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              buildingsEnabled: false,
              padding: EdgeInsets.only(top: 140, bottom: 120 + bottomInset),
            ),

            // Top: back + search + filters.
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Row(
                      children: [
                        GlassIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: PressableScale(
                            onTap: _openSearch,
                            child: GlassPanel(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: AppSpace.sm),
                                  Expanded(
                                    child: Text(
                                      'Search campus',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).fadeSlideIn(),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _MapChip(
                          label: 'All',
                          selected: _filter == null,
                          onTap: () => setState(() => _filter = null),
                        ),
                        for (final c in categories)
                          _MapChip(
                            label: c.pluralLabel,
                            icon: c.icon,
                            color: c.color,
                            selected: _filter == c,
                            onTap: () => setState(() {
                              _filter = _filter == c ? null : c;
                              if (_selected != null &&
                                  _filter != null &&
                                  _selected!.category != _filter) {
                                _selected = null;
                              }
                            }),
                          ),
                      ],
                    ).fadeSlideIn(index: 1, rise: 0.3),
                  ),
                ],
              ),
            ),

            // Right-side controls.
            AnimatedPositioned(
              duration: AppMotion.slow,
              curve: AppMotion.emphasized,
              right: 16,
              bottom: (_selected != null ? 196 : 28) + bottomInset,
              child: Column(
                children: [
                  GlassIconButton(
                    icon: Icons.center_focus_strong_rounded,
                    tooltip: 'Show whole campus',
                    onPressed: _recentre,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  GlassIconButton(
                    icon: _locating
                        ? Icons.more_horiz_rounded
                        : Icons.my_location_rounded,
                    tooltip: 'My location',
                    iconColor: AppColors.route,
                    onPressed: _locating ? null : _locateMe,
                  ),
                ],
              ).fadeSlideIn(index: 2),
            ),

            // Loading markers pill.
            if (!_markersReady)
              Positioned(
                left: 0,
                right: 0,
                bottom: 32 + bottomInset,
                child: Center(
                  child: GlassPanel(
                    borderRadius: AppRadius.pillAll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Loading campus…',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Selected building card.
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + bottomInset,
              child: AnimatedSwitcher(
                duration: AppMotion.slow,
                switchInCurve: AppMotion.emphasized,
                switchOutCurve: AppMotion.exit,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _selected == null
                    ? const SizedBox.shrink(key: ValueKey('none'))
                    : _SelectedCard(
                        key: ValueKey(_selected!.id),
                        building: _selected!,
                        onClose: () => setState(() => _selected = null),
                        onDirections: () => _directions(_selected!),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({
    super.key,
    required this.building,
    required this.onClose,
    required this.onDirections,
  });

  final Building building;
  final VoidCallback onClose;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.raised(AppColors.primaryDeep),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CategoryIcon(category: building.category, size: 52).popIn(),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: text.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    CategoryLabel(category: building.category),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          GradientButton(
            label: 'Get directions',
            icon: Icons.directions_rounded,
            height: 50,
            onPressed: onDirections,
          ),
        ],
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpace.xs),
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? (color ?? AppColors.primary)
                : cs.surface.withValues(alpha: 0.92),
            borderRadius: AppRadius.pillAll,
            boxShadow: AppShadows.soft(AppColors.primaryDeep),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? fg : color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontSize: 13, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
