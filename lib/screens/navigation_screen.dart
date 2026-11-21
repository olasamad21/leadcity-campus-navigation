import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/building.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../services/voice_navigation_controller.dart';
import '../services/voice_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/map_styles.dart';
import '../utils/map_markers.dart';
import '../utils/route_geometry.dart';
import '../widgets/arrival_overlay.dart';
import '../widgets/premium/glass_panel.dart';
import '../widgets/premium/pressable_scale.dart';
import 'home_screen.dart';

/// Walking speed used for every ETA in the app (80 m/min, same as routing).
const double kWalkingSpeedMps = 80 / 60;

/// Turn-by-turn navigation.
///
/// Live mode follows GPS. [demo] mode walks the route automatically (with the
/// same banner, voice prompts and arrival screen) so the full experience can
/// be shown anywhere without moving.
class NavigationScreen extends StatefulWidget {
  final RouteInfo routeInfo;
  final Building startBuilding;
  final Building endBuilding;
  final bool demo;

  const NavigationScreen({
    super.key,
    required this.routeInfo,
    required this.startBuilding,
    required this.endBuilding,
    this.demo = false,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  static const _tick = Duration(milliseconds: 250);
  static const _snapMeters = 25.0;
  static const _demoSpeeds = [1.0, 2.0, 4.0];

  final LocationService _locationService = LocationService();
  final NavigationService _navigationService = NavigationService();
  final VoiceService _voiceService = VoiceService();
  late final VoiceNavigationController _voice;
  late final RouteGeometry _geometry;
  late final List<TurnStep> _steps;

  GoogleMapController? _mapController;
  StreamSubscription<dynamic>? _gpsSub;
  Timer? _demoTimer;

  /// Metres walked along the route.
  double _progress = 0;
  LatLng? _position;
  double _heading = 0;
  bool _offRoute = false;
  bool _waitingForGps = true;
  bool _gpsFailed = false;
  bool _followCamera = true;
  bool _arrived = false;
  bool _markersReady = false;

  // Demo controls.
  bool _demoPaused = false;
  int _demoSpeedIndex = 1;

  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _geometry = RouteGeometry(widget.routeInfo.polylinePoints);
    _steps = turnStepsFor(widget.routeInfo.campusRoute, _geometry);
    _voice = VoiceNavigationController(widget.routeInfo.campusRoute, _voiceService);
    _position = _geometry.points.isEmpty ? null : _geometry.points.first;
    _heading = _geometry.bearingAt(0);
    MapMarkers.warmUp().then((_) {
      if (mounted) setState(() => _markersReady = true);
    });
    _bootstrap();
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _demoTimer?.cancel();
    _voice.reset();
    _voiceService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _voiceService.initialize();
    if (!mounted) return;
    unawaited(_voiceService.speak(
      'Starting route to ${widget.endBuilding.name}. '
      '${widget.routeInfo.campusRoute.estimatedWalkingMinutes} minute walk.',
    ));
    if (widget.demo) {
      setState(() => _waitingForGps = false);
      _startDemo();
    } else {
      await _startGps();
    }
  }

  // ── position sources ───────────────────────────────────────────────────

  Future<void> _startGps() async {
    // Ensures permission is granted before opening the stream.
    final first = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (first == null) {
      setState(() {
        _gpsFailed = true;
        _waitingForGps = false;
      });
      return;
    }
    _onRawPosition(_locationService.positionToLatLng(first));
    _gpsSub = _locationService.getPositionStream()?.listen(
          (p) => _onRawPosition(_locationService.positionToLatLng(p)),
          onError: (_) {
            if (mounted) setState(() => _gpsFailed = true);
          },
        );
  }

  void _startDemo() {
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(_tick, (_) {
      if (_demoPaused || _arrived) return;
      final step = kWalkingSpeedMps *
          _demoSpeeds[_demoSpeedIndex] *
          (_tick.inMilliseconds / 1000);
      final next = (_progress + step).clamp(0.0, _geometry.length);
      _applyProgress(next, _geometry.pointAt(next), offRoute: false);
    });
  }

  void _switchToDemo() {
    _gpsSub?.cancel();
    _gpsSub = null;
    setState(() {
      _gpsFailed = false;
      _waitingForGps = false;
    });
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => NavigationScreen(
        routeInfo: widget.routeInfo,
        startBuilding: widget.startBuilding,
        endBuilding: widget.endBuilding,
        demo: true,
      ),
    ));
  }

  void _onRawPosition(LatLng raw) {
    final proj = _geometry.project(raw, minAlong: _progress - 15);
    final onRoute = proj.offsetMeters <= _snapMeters;
    _applyProgress(
      onRoute ? proj.alongMeters : _progress,
      onRoute ? proj.point : raw,
      offRoute: !onRoute,
    );
  }

  void _applyProgress(double along, LatLng shown, {required bool offRoute}) {
    if (!mounted || _arrived) return;
    final moved = along - _progress;
    final heading = moved.abs() > 0.3 ? _geometry.bearingAt(along) : _heading;

    _voice.onLocationUpdate(shown);
    final remaining = (_geometry.length - along).clamp(0.0, double.infinity);
    // checkArrival speaks the arrival message when near the entrance; the end
    // of the path can sit a few metres away, so also arrive there.
    final nearEntrance =
        _voice.checkArrival(shown, widget.routeInfo.endLocation);
    final arrived = nearEntrance || remaining <= 8;
    if (arrived && !nearEntrance && !_arrived) {
      unawaited(_voiceService.speak('You have arrived at your destination.'));
    }

    setState(() {
      _progress = along;
      _position = shown;
      _heading = heading;
      _offRoute = offRoute;
      _waitingForGps = false;
    });
    if (_followCamera) _moveCamera();
    if (arrived) _onArrived();
  }

  void _moveCamera() {
    final p = _position;
    if (p == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: p, zoom: 18.6, tilt: 55, bearing: _heading),
      ),
    );
  }

  void _onArrived() {
    if (_arrived) return;
    _demoTimer?.cancel();
    _gpsSub?.cancel();
    setState(() {
      _arrived = true;
      _progress = _geometry.length;
    });
  }

  // ── UI actions ─────────────────────────────────────────────────────────

  void _goHome() {
    _demoTimer?.cancel();
    _gpsSub?.cancel();
    _voice.reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _confirmEnd() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.flag_outlined, color: AppColors.error),
        title: const Text('End navigation?'),
        content: Text(
          'You are ${_navigationService.formatDistance(_remaining)} from '
          '${widget.endBuilding.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (end == true && mounted) _goHome();
  }

  void _toggleMute() {
    HapticFeedback.selectionClick();
    setState(_voiceService.toggleMute);
  }

  void _recentre() {
    setState(() => _followCamera = true);
    _moveCamera();
  }

  double get _remaining =>
      (_geometry.length - _progress).clamp(0.0, double.infinity);

  // ── map layers ─────────────────────────────────────────────────────────

  Set<Polyline> _polylines() {
    final walked = _geometry.sliceTo(_progress);
    final ahead = _geometry.sliceFrom(_progress);
    return {
      if (walked.length >= 2)
        Polyline(
          polylineId: const PolylineId('walked'),
          points: walked,
          color: AppColors.routeWalked,
          width: 7,
          zIndex: 1,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      if (ahead.length >= 2) ...{
        Polyline(
          polylineId: const PolylineId('casing'),
          points: ahead,
          color: Colors.white,
          width: 13,
          zIndex: 2,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
        Polyline(
          polylineId: const PolylineId('ahead'),
          points: ahead,
          color: AppColors.route,
          width: 8,
          zIndex: 3,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      },
    };
  }

  Set<Marker> _markers() {
    if (!_markersReady) return const {};
    final dot = MapMarkers.cachedUserDot;
    final dest = MapMarkers.cachedDestination;
    final p = _position;
    return {
      if (dest != null)
        Marker(
          markerId: const MarkerId('dest'),
          position: widget.routeInfo.endLocation,
          icon: dest,
          anchor: const Offset(0.5, 0.96),
          zIndexInt: 4,
        ),
      if (dot != null && p != null)
        Marker(
          markerId: const MarkerId('me'),
          position: p,
          icon: dot,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          rotation: _heading,
          zIndexInt: 5,
        ),
    };
  }

  // ── build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nextIndex = _steps.indexWhere((s) => s.alongMeters > _progress + 1);
    final next = nextIndex < 0 ? null : _steps[nextIndex];
    final then = (nextIndex >= 0 && nextIndex + 1 < _steps.length)
        ? _steps[nextIndex + 1]
        : null;
    final remaining = _remaining;
    final total = _geometry.length <= 0 ? 1.0 : _geometry.length;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_arrived) {
          _goHome();
        } else {
          _confirmEnd();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                style: MapStyles.of(context),
                initialCameraPosition: CameraPosition(
                  target: _position ?? widget.routeInfo.startLocation,
                  zoom: 18.6,
                  tilt: 55,
                  bearing: _heading,
                ),
                minMaxZoomPreference: const MinMaxZoomPreference(15.5, 20),
                onMapCreated: (c) {
                  _mapController = c;
                  _moveCamera();
                },
                polylines: _polylines(),
                markers: _markers(),
                padding: EdgeInsets.only(top: 170, bottom: 200 + bottomInset),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                buildingsEnabled: true,
              ),
              // Stop auto-follow when the user drags the map.
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerMove: (_) {
                    if (_followCamera) setState(() => _followCamera = false);
                  },
                ),
              ),

              // Turn banner.
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TurnBanner(
                        step: next,
                        distanceToStep: next == null
                            ? remaining
                            : (next.alongMeters - _progress).clamp(0, total),
                        destinationName: widget.endBuilding.name,
                        formatDistance: _navigationService.formatDistance,
                        waitingForGps: _waitingForGps,
                      ),
                      if (then != null && next != null)
                        _ThenChip(step: then)
                            .animate(key: ValueKey(then))
                            .fadeIn(duration: AppMotion.medium)
                            .slideY(begin: -0.4, end: 0),
                      const SizedBox(height: AppSpace.xs),
                      Row(
                        children: [
                          if (widget.demo) _DemoBadge(paused: _demoPaused),
                          if (_offRoute) const _OffRouteBadge(),
                          const Spacer(),
                          GlassIconButton(
                            icon: _voiceService.isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            tooltip: _voiceService.isMuted ? 'Unmute' : 'Mute',
                            onPressed: _toggleMute,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Re-centre button when the user has panned away.
              Positioned(
                right: 16,
                bottom: 210 + bottomInset,
                child: AnimatedScale(
                  scale: _followCamera ? 0 : 1,
                  duration: AppMotion.medium,
                  curve: AppMotion.spring,
                  child: GlassIconButton(
                    icon: Icons.navigation_rounded,
                    iconColor: AppColors.route,
                    tooltip: 'Re-centre',
                    onPressed: _recentre,
                  ),
                ),
              ),

              // Bottom trip panel.
              Align(
                alignment: Alignment.bottomCenter,
                child: _TripPanel(
                  remainingMeters: remaining,
                  progress: (_progress / total).clamp(0.0, 1.0),
                  formatDistance: _navigationService.formatDistance,
                  demo: widget.demo,
                  demoPaused: _demoPaused,
                  demoSpeed: _demoSpeeds[_demoSpeedIndex],
                  onToggleDemoPause: () =>
                      setState(() => _demoPaused = !_demoPaused),
                  onCycleDemoSpeed: () => setState(() => _demoSpeedIndex =
                      (_demoSpeedIndex + 1) % _demoSpeeds.length),
                  onEnd: _confirmEnd,
                ),
              ),

              if (_gpsFailed && !_arrived)
                _GpsProblem(
                  onRetry: () {
                    setState(() {
                      _gpsFailed = false;
                      _waitingForGps = true;
                    });
                    _startGps();
                  },
                  onDemo: _switchToDemo,
                ),

              if (_arrived)
                Positioned.fill(
                  child: ArrivalOverlay(
                    destination: widget.endBuilding,
                    distanceLabel:
                        _navigationService.formatDistance(_geometry.length),
                    durationLabel: _elapsedLabel(),
                    onDone: _goHome,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _elapsedLabel() {
    final s = DateTime.now().difference(_startedAt).inSeconds;
    if (s < 60) return '${s}s';
    return '${s ~/ 60}m ${s % 60}s';
  }
}

// ── pieces ───────────────────────────────────────────────────────────────

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({
    required this.step,
    required this.distanceToStep,
    required this.destinationName,
    required this.formatDistance,
    required this.waitingForGps,
  });

  final TurnStep? step;
  final double distanceToStep;
  final String destinationName;
  final String Function(double) formatDistance;
  final bool waitingForGps;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final icon = waitingForGps
        ? Icons.gps_not_fixed_rounded
        : step?.icon ?? Icons.flag_rounded;
    final title = waitingForGps
        ? 'Finding your position…'
        : step?.instruction ?? 'Continue to $destinationName';
    final now = step != null && distanceToStep <= 15;

    return AnimatedContainer(
      duration: AppMotion.slow,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: now
            ? const LinearGradient(
                colors: [Color(0xFF3E7BFA), Color(0xFF2E5BD8)],
              )
            : AppColors.brandGradient,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.raised(AppColors.primaryDeep),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: AppMotion.slow,
            transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: AppMotion.spring),
              child: c,
            ),
            child: Container(
              key: ValueKey(icon),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(icon, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              layoutBuilder: (cur, prev) => Stack(
                alignment: Alignment.centerLeft,
                children: [...prev, if (cur != null) cur],
              ),
              child: Column(
                key: ValueKey(title),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!waitingForGps)
                    Text(
                      now ? 'Now' : 'In ${formatDistance(distanceToStep)}',
                      style: text.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: -0.3, end: 0);
  }
}

class _ThenChip extends StatelessWidget {
  const _ThenChip({required this.step});
  final TurnStep step;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, top: 0),
        padding: const EdgeInsets.fromLTRB(12, 6, 14, 8),
        decoration: const BoxDecoration(
          color: AppColors.primaryDeep,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Then',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(width: 6),
            Icon(step.icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge({required this.paused});
  final bool paused;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: AppRadius.pillAll,
        boxShadow: AppShadows.glow(AppColors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill_rounded,
              size: 16, color: AppColors.primaryDeep),
          const SizedBox(width: 6),
          Text(
            paused ? 'Demo paused' : 'Demo mode',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryDeep,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1, end: 1.04, duration: 900.ms);
  }
}

class _OffRouteBadge extends StatelessWidget {
  const _OffRouteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        'Head back to the blue path',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    ).animate().fadeIn().shakeX(hz: 3, amount: 3);
  }
}

class _TripPanel extends StatelessWidget {
  const _TripPanel({
    required this.remainingMeters,
    required this.progress,
    required this.formatDistance,
    required this.demo,
    required this.demoPaused,
    required this.demoSpeed,
    required this.onToggleDemoPause,
    required this.onCycleDemoSpeed,
    required this.onEnd,
  });

  final double remainingMeters;
  final double progress;
  final String Function(double) formatDistance;
  final bool demo;
  final bool demoPaused;
  final double demoSpeed;
  final VoidCallback onToggleDemoPause;
  final VoidCallback onCycleDemoSpeed;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final minutes = (remainingMeters / kWalkingSpeedMps / 60).ceil();
    final arrival = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(seconds: (remainingMeters / kWalkingSpeedMps).round())),
    ).format(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.sheet,
        boxShadow: AppShadows.raised(AppColors.primaryDeep),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar.
              ClipRRect(
                borderRadius: AppRadius.pillAll,
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: cs.surfaceContainerHighest),
                      AnimatedFractionallySizedBox(
                        duration: AppMotion.slow,
                        widthFactor: progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.accentGradient,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${minutes < 1 ? '<1' : minutes}',
                              style: text.displayLarge?.copyWith(
                                fontSize: 36,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('min', style: text.titleMedium),
                            ),
                          ],
                        ),
                        Text(
                          '${formatDistance(remainingMeters)} · arrive $arrival',
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (demo) ...[
                    _RoundButton(
                      icon: demoPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      tooltip: demoPaused ? 'Resume demo' : 'Pause demo',
                      onTap: onToggleDemoPause,
                    ),
                    const SizedBox(width: AppSpace.xs),
                    _RoundButton(
                      label: '${demoSpeed.toStringAsFixed(0)}×',
                      tooltip: 'Demo speed',
                      onTap: onCycleDemoSpeed,
                    ),
                    const SizedBox(width: AppSpace.xs),
                  ],
                  _RoundButton(
                    icon: Icons.close_rounded,
                    tooltip: 'End navigation',
                    color: AppColors.error,
                    onTap: onEnd,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(
          begin: 1,
          end: 0,
          duration: AppMotion.slower,
          curve: AppMotion.emphasized,
        );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.onTap,
    this.icon,
    this.label,
    this.color,
  });

  final String tooltip;
  final VoidCallback onTap;
  final IconData? icon;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.onSurface;
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: (color ?? cs.onSurface).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: fg)
              : Text(
                  label ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: fg),
                ),
        ),
      ),
    );
  }
}

class _GpsProblem extends StatelessWidget {
  const _GpsProblem({required this.onRetry, required this.onDemo});

  final VoidCallback onRetry;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.lgAll,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 48, color: AppColors.warning),
              const SizedBox(height: AppSpace.md),
              Text('GPS not available', style: text.titleLarge),
              const SizedBox(height: AppSpace.xs),
              Text(
                'Turn on location and allow access, or watch this route '
                'in Demo mode instead.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpace.lg),
              FilledButton.icon(
                onPressed: onDemo,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Play demo'),
              ),
              const SizedBox(height: AppSpace.xs),
              TextButton(onPressed: onRetry, child: const Text('Try GPS again')),
            ],
          ),
        ).animate().scaleXY(begin: 0.9, end: 1, curve: AppMotion.spring),
      ),
    );
  }
}
