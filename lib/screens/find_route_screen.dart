import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/building.dart';
import '../models/building_category.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/category_icon.dart';
import '../widgets/premium/gradient_button.dart';
import '../widgets/premium/motion.dart';
import '../widgets/premium/pressable_scale.dart';
import '../widgets/premium/skeleton.dart';
import 'building_search_screen.dart';
import 'route_preview_screen.dart';

/// Placeholder [Building] for preview/navigation when the route starts from live GPS.
Building _gpsOriginBuilding(LatLng latLng) {
  return Building(
    id: '__gps_current_location',
    name: 'Your location',
    type: 'Other',
    entrancePoint: latLng,
    polygonCoordinates: const [],
  );
}

/// Pick a start and destination; the route is solved as soon as both are set.
class FindRouteScreen extends StatefulWidget {
  final Building? initialDestination;

  const FindRouteScreen({super.key, this.initialDestination});

  @override
  State<FindRouteScreen> createState() => _FindRouteScreenState();
}

class _FindRouteScreenState extends State<FindRouteScreen> {
  final NavigationService _navigationService = NavigationService();
  final LocationService _locationService = LocationService();

  Building? _startBuilding;

  /// When set, "From" is live GPS (snapped onto the campus graph).
  LatLng? _startGpsLatLng;
  Building? _destinationBuilding;

  bool _isCalculating = false;
  bool _isAcquiringGps = false;
  String? _errorMessage;
  RouteInfo? _routeInfo;
  double _swapTurns = 0;

  @override
  void initState() {
    super.initState();
    _destinationBuilding = widget.initialDestination;
  }

  bool get _hasStart => _startBuilding != null || _startGpsLatLng != null;

  Future<void> _pickStart() async {
    final picked = await Navigator.of(context).push<Building>(
      MaterialPageRoute(
        builder: (_) => BuildingSearchScreen(
          hint: 'Where are you starting from?',
          allowCurrentLocation: true,
          excludeId: _destinationBuilding?.id,
        ),
      ),
    );
    if (picked == null || !mounted) return;
    if (BuildingSearchScreen.isCurrentLocation(picked)) {
      await _useCurrentLocation();
      return;
    }
    setState(() {
      _startBuilding = picked;
      _startGpsLatLng = null;
      _routeInfo = null;
      _errorMessage = null;
    });
    _calculateRouteIfReady();
  }

  Future<void> _pickDestination() async {
    final picked = await Navigator.of(context).push<Building>(
      MaterialPageRoute(
        builder: (_) => BuildingSearchScreen(
          hint: 'Where do you want to go?',
          excludeId: _startBuilding?.id,
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _destinationBuilding = picked;
      _routeInfo = null;
      _errorMessage = null;
    });
    _calculateRouteIfReady();
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
            'Could not get your location. Please choose a starting building.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _startGpsLatLng = _locationService.positionToLatLng(position);
      _startBuilding = null;
      _routeInfo = null;
      _errorMessage = null;
    });
    _calculateRouteIfReady();
  }

  void _swap() {
    if (_startGpsLatLng != null) return; // GPS can't be a destination.
    HapticFeedback.lightImpact();
    setState(() {
      _swapTurns += 0.5;
      final s = _startBuilding;
      _startBuilding = _destinationBuilding;
      _destinationBuilding = s;
      _routeInfo = null;
      _errorMessage = null;
    });
    _calculateRouteIfReady();
  }

  Building? _startAsBuildingForNavigation() {
    if (_startBuilding != null) return _startBuilding;
    if (_startGpsLatLng != null) return _gpsOriginBuilding(_startGpsLatLng!);
    return null;
  }

  Future<void> _calculateRouteIfReady() async {
    if (_destinationBuilding == null || !_hasStart) return;

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      // Let the loading state render for a beat so the change is perceptible.
      final results = await Future.wait<Object?>([
        _startGpsLatLng != null
            ? _navigationService.calculateRoute(
                origin: _startGpsLatLng!,
                destination: _destinationBuilding!.entrancePoint,
              )
            : _navigationService.calculateRouteBetweenBuildings(
                startBuilding: _startBuilding!,
                endBuilding: _destinationBuilding!,
              ),
        Future<void>.delayed(const Duration(milliseconds: 350)),
      ]);
      final route = results.first as RouteInfo?;

      if (!mounted) return;
      setState(() {
        _isCalculating = false;
        if (route != null) {
          _routeInfo = route;
          HapticFeedback.lightImpact();
        } else {
          _errorMessage =
              'These two places are not connected on the campus walkway map. '
              'Try a different start or destination.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCalculating = false;
        _errorMessage = 'Something went wrong while finding a route.';
      });
    }
  }

  void _openPreview() {
    final startNav = _startAsBuildingForNavigation();
    if (_routeInfo == null || startNav == null || _destinationBuilding == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutePreviewScreen(
          routeInfo: _routeInfo,
          startBuilding: startNav,
          endBuilding: _destinationBuilding!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final startLabel = _startGpsLatLng != null
        ? 'Your location'
        : _startBuilding?.name;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                        tooltip: 'Back',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          'Plan your walk',
                          style: text.displayMedium
                              ?.copyWith(color: Colors.white),
                        ).fadeSlideIn(),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _RouteFieldsCard(
                          startLabel: startLabel,
                          startCategory: _startBuilding?.category,
                          startIsGps: _startGpsLatLng != null,
                          destinationLabel: _destinationBuilding?.name,
                          destinationCategory: _destinationBuilding?.category,
                          onTapStart: _pickStart,
                          onTapDestination: _pickDestination,
                          onSwap: _startGpsLatLng == null ? _swap : null,
                          swapTurns: _swapTurns,
                        ).fadeSlideIn(index: 1),
                      ),
                      if (!_hasStart) ...[
                        const SizedBox(height: AppSpace.sm),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _LocationChip(
                            loading: _isAcquiringGps,
                            onTap: _useCurrentLocation,
                          ).fadeSlideIn(index: 2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: AnimatedSwitcher(
                duration: AppMotion.slow,
                switchInCurve: AppMotion.emphasized,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isCalculating || _isAcquiringGps) {
      return const _SummarySkeleton(key: ValueKey('loading'));
    }
    if (_errorMessage != null) {
      return _ErrorCard(
        key: const ValueKey('error'),
        message: _errorMessage!,
      );
    }
    if (_routeInfo != null) {
      return _RouteSummary(
        key: ValueKey(_routeInfo),
        route: _routeInfo!,
        formatDistance: _navigationService.formatDistance,
        onPreview: _openPreview,
      );
    }
    return _EmptyHint(
      key: const ValueKey('hint'),
      needsStart: !_hasStart,
    );
  }
}

class _RouteFieldsCard extends StatelessWidget {
  const _RouteFieldsCard({
    required this.startLabel,
    required this.startCategory,
    required this.startIsGps,
    required this.destinationLabel,
    required this.destinationCategory,
    required this.onTapStart,
    required this.onTapDestination,
    required this.onSwap,
    required this.swapTurns,
  });

  final String? startLabel;
  final BuildingCategory? startCategory;
  final bool startIsGps;
  final String? destinationLabel;
  final BuildingCategory? destinationCategory;
  final VoidCallback onTapStart;
  final VoidCallback onTapDestination;
  final VoidCallback? onSwap;
  final double swapTurns;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.raised(AppColors.primaryDeep),
      ),
      child: Row(
        children: [
          // Route rail: start dot, dotted line, destination pin.
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.success, width: 3.5),
                ),
              ),
              for (var i = 0; i < 5; i++)
                Container(
                  width: 2,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: cs.outlineVariant,
                ),
              const Icon(Icons.location_on_rounded,
                  color: AppColors.error, size: 20),
            ],
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              children: [
                _FieldRow(
                  caption: 'From',
                  value: startLabel,
                  placeholder: 'Choose starting point',
                  icon: startIsGps ? Icons.my_location_rounded : null,
                  category: startCategory,
                  onTap: onTapStart,
                ),
                Divider(height: 1, color: cs.outlineVariant),
                _FieldRow(
                  caption: 'To',
                  value: destinationLabel,
                  placeholder: 'Choose destination',
                  category: destinationCategory,
                  onTap: onTapDestination,
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: swapTurns,
            duration: AppMotion.slow,
            curve: AppMotion.spring,
            child: IconButton(
              tooltip: 'Swap start and destination',
              onPressed: onSwap,
              icon: const Icon(Icons.swap_vert_rounded),
              style: IconButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.caption,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.category,
    this.icon,
  });

  final String caption;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final BuildingCategory? category;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(caption, style: text.labelMedium),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: AppMotion.medium,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previous, if (current != null) current],
                    ),
                    child: Text(
                      value ?? placeholder,
                      key: ValueKey(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: value == null
                          ? text.bodyLarge
                              ?.copyWith(color: cs.onSurfaceVariant)
                          : text.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              Icon(icon, color: AppColors.route, size: 20)
            else if (category != null)
              CategoryIcon(category: category!, size: 28),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.my_location_rounded,
                  size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              loading ? 'Finding you…' : 'Start from my location',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({
    super.key,
    required this.route,
    required this.formatDistance,
    required this.onPreview,
  });

  final RouteInfo route;
  final String Function(double) formatDistance;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final campus = route.campusRoute;
    final turns = campus.instructions.length;
    final arrival = DateTime.now()
        .add(Duration(minutes: campus.estimatedWalkingMinutes));
    final arrivalLabel = TimeOfDay.fromDateTime(arrival).format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: cs.outlineVariant),
            boxShadow: AppShadows.soft(AppColors.primaryDeep),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      'Best walking route',
                      style: text.labelMedium
                          ?.copyWith(color: AppColors.success),
                    ),
                  ),
                  const Spacer(),
                  Text('Arrive $arrivalLabel', style: text.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountUpText(
                    value: campus.estimatedWalkingMinutes.toDouble(),
                    format: (v) => '${v.round()}',
                    style: text.displayLarge?.copyWith(fontSize: 44),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('min walk', style: text.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  _Stat(
                    icon: Icons.straighten_rounded,
                    child: CountUpText(
                      value: campus.totalDistanceMeters,
                      format: formatDistance,
                      style: text.titleMedium,
                    ),
                    caption: 'Distance',
                  ),
                  const SizedBox(width: AppSpace.lg),
                  _Stat(
                    icon: Icons.turn_right_rounded,
                    child: Text('$turns', style: text.titleMedium),
                    caption: turns == 1 ? 'Turn' : 'Turns',
                  ),
                  const SizedBox(width: AppSpace.lg),
                  _Stat(
                    icon: Icons.record_voice_over_rounded,
                    child: Text('On', style: text.titleMedium),
                    caption: 'Voice',
                  ),
                ],
              ),
            ],
          ),
        ).fadeSlideIn(),
        const SizedBox(height: AppSpace.lg),
        GradientButton(
          label: 'Preview route',
          icon: Icons.map_rounded,
          onPressed: onPreview,
        ).fadeSlideIn(index: 2),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.child, required this.caption});

  final IconData icon;
  final Widget child;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            Text(caption, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 130, height: 22, borderRadius: AppRadius.pillAll),
          SizedBox(height: AppSpace.md),
          Skeleton(width: 160, height: 44),
          SizedBox(height: AppSpace.md),
          Row(
            children: [
              Skeleton(width: 80, height: 32),
              SizedBox(width: AppSpace.lg),
              Skeleton(width: 60, height: 32),
              SizedBox(width: AppSpace.lg),
              Skeleton(width: 60, height: 32),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wrong_location_rounded, color: AppColors.error),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No route found', style: text.titleMedium),
                const SizedBox(height: 4),
                Text(message, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ).animate().shakeX(hz: 4, amount: 4, duration: 400.ms);
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({super.key, required this.needsStart});
  final bool needsStart;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: AppSpace.lg),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.route.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_walk_rounded,
              size: 46, color: AppColors.route),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -4, end: 4, duration: 1400.ms, curve: Curves.easeInOut),
        const SizedBox(height: AppSpace.lg),
        Text(
          needsStart ? 'Where are you starting from?' : 'Where are you going?',
          style: text.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Pick both places and the best walking route appears here.',
          style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    ).fadeSlideIn();
  }
}
