import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/building.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/map_styles.dart';
import '../utils/map_markers.dart';
import '../utils/route_geometry.dart';
import '../widgets/premium/glass_panel.dart';
import '../widgets/premium/gradient_button.dart';
import '../widgets/offline_banner.dart';
import '../widgets/premium/motion.dart';
import 'navigation_screen.dart';

/// Route overview: the path draws itself on the map, then a sheet lists the
/// steps with options to start live navigation or a GPS-free demo.
class RoutePreviewScreen extends StatefulWidget {
  /// When null, shows a "no route" state.
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

class _RoutePreviewScreenState extends State<RoutePreviewScreen>
    with SingleTickerProviderStateMixin {
  final NavigationService _navigationService = NavigationService();
  GoogleMapController? _mapController;
  late final AnimationController _draw;
  RouteGeometry? _geometry;
  List<TurnStep> _steps = const [];
  bool _markersReady = false;

  static const double _sheetFraction = 0.46;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() => setState(() {}));

    final route = widget.routeInfo;
    if (route != null) {
      _geometry = RouteGeometry(route.polylinePoints);
      _steps = turnStepsFor(route.campusRoute, _geometry!);
    }
    MapMarkers.warmUp().then((_) {
      if (mounted) setState(() => _markersReady = true);
    });
  }

  @override
  void dispose() {
    _draw.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    final g = _geometry;
    if (g == null || g.points.isEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await controller.animateCamera(CameraUpdate.newLatLngBounds(g.bounds(), 56));
    if (mounted) _draw.forward();
  }

  void _start({required bool demo}) {
    final route = widget.routeInfo;
    if (route == null) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => NavigationScreen(
          routeInfo: route,
          startBuilding: widget.startBuilding,
          endBuilding: widget.endBuilding,
          demo: demo,
        ),
      ),
    );
  }

  Set<Polyline> _polylines() {
    final g = _geometry;
    if (g == null) return const {};
    final t = Curves.easeInOutCubic.transform(_draw.value);
    final drawn = g.sliceTo(g.length * t);
    if (drawn.length < 2) return const {};
    return {
      Polyline(
        polylineId: const PolylineId('casing'),
        points: drawn,
        color: Colors.white,
        width: 12,
        zIndex: 1,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      Polyline(
        polylineId: const PolylineId('route'),
        points: drawn,
        color: AppColors.route,
        width: 7,
        zIndex: 2,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _markers() {
    final route = widget.routeInfo;
    if (route == null || !_markersReady) return const {};
    final start = MapMarkers.cachedStart;
    final dest = MapMarkers.cachedDestination;
    return {
      if (start != null)
        Marker(
          markerId: const MarkerId('start'),
          position: route.startLocation,
          icon: start,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 3,
        ),
      if (dest != null && _draw.value > 0.92)
        Marker(
          markerId: const MarkerId('end'),
          position: route.endLocation,
          icon: dest,
          anchor: const Offset(0.5, 0.96),
          zIndexInt: 4,
          infoWindow: InfoWindow(title: widget.endBuilding.name),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.routeInfo;
    if (route == null) return _NoRoute(onBack: () => Navigator.pop(context));

    final height = MediaQuery.of(context).size.height;
    final sheetHeight = height * _sheetFraction;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                style: MapStyles.of(context),
                initialCameraPosition: CameraPosition(
                  target: route.startLocation,
                  zoom: 16.5,
                ),
                onMapCreated: _onMapCreated,
                polylines: _polylines(),
                markers: _markers(),
                padding: EdgeInsets.only(top: 60, bottom: sheetHeight - 20),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                buildingsEnabled: false,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ).fadeSlideIn(),
                    const SizedBox(width: AppSpace.sm),
                    const Expanded(child: OfflineBanner()),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _PreviewSheet(
                height: sheetHeight,
                route: route,
                steps: _steps,
                start: widget.startBuilding,
                end: widget.endBuilding,
                formatDistance: _navigationService.formatDistance,
                onStart: () => _start(demo: false),
                onDemo: () => _start(demo: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSheet extends StatelessWidget {
  const _PreviewSheet({
    required this.height,
    required this.route,
    required this.steps,
    required this.start,
    required this.end,
    required this.formatDistance,
    required this.onStart,
    required this.onDemo,
  });

  final double height;
  final RouteInfo route;
  final List<TurnStep> steps;
  final Building start;
  final Building end;
  final String Function(double) formatDistance;
  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final campus = route.campusRoute;
    final total = campus.totalDistanceMeters;

    // Step rows: start, each turn (with distance from previous point), arrive.
    final rows = <Widget>[];
    rows.add(_StepRow(
      icon: Icons.trip_origin_rounded,
      iconColor: AppColors.success,
      title: 'Start at ${start.name}',
      subtitle: steps.isEmpty
          ? 'Walk ${formatDistance(total)} along the path'
          : 'Walk ${formatDistance(steps.first.alongMeters)}',
    ));
    for (var i = 0; i < steps.length; i++) {
      final next = i + 1 < steps.length ? steps[i + 1].alongMeters : total;
      rows.add(_StepRow(
        icon: steps[i].icon,
        iconColor: AppColors.route,
        title: steps[i].instruction,
        subtitle: 'Then walk ${formatDistance((next - steps[i].alongMeters).clamp(0, total))}',
      ));
    }
    rows.add(_StepRow(
      icon: Icons.flag_rounded,
      iconColor: AppColors.error,
      title: 'Arrive at ${end.name}',
      subtitle: 'Your destination',
      isLast: true,
    ));

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.sheet,
        boxShadow: AppShadows.raised(AppColors.primaryDeep),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CountUpText(
                  value: campus.estimatedWalkingMinutes.toDouble(),
                  format: (v) => '${v.round()} min',
                  style: text.displayMedium,
                ),
                const SizedBox(width: AppSpace.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${formatDistance(total)} · ${steps.length} '
                    '${steps.length == 1 ? 'turn' : 'turns'}',
                    style: text.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ).fadeSlideIn(index: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'To ${end.name}',
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ).fadeSlideIn(index: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              itemCount: rows.length,
              itemBuilder: (_, i) =>
                  rows[i].fadeSlideIn(index: 2 + (i < 8 ? i : 8), rise: 0.15),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GradientButton(
                      label: 'Start',
                      icon: Icons.navigation_rounded,
                      onPressed: onStart,
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: onDemo,
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: const Text('Demo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).fadeSlideIn(index: 3),
        ],
      ),
    ).animate().slideY(
          begin: 0.25,
          end: 0,
          duration: AppMotion.slower,
          curve: AppMotion.emphasized,
        );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: cs.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: text.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoRoute extends StatelessWidget {
  const _NoRoute({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Route preview')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wrong_location_rounded,
                  size: 64, color: AppColors.error),
              const SizedBox(height: AppSpace.md),
              Text('No route found', style: text.titleLarge),
              const SizedBox(height: AppSpace.xs),
              Text(
                'These places are not connected on the campus walkway map.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpace.lg),
              OutlinedButton(onPressed: onBack, child: const Text('Go back')),
            ],
          ),
        ),
      ),
    );
  }
}
