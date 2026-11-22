import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Accuracy-aware GPS smoother (1-state Kalman filter per axis, in metres).
///
/// Each fix is weighted by its reported accuracy: a precise fix moves the
/// estimate almost all the way, a noisy one only a little. Between fixes the
/// uncertainty grows with time at walking pace, so the estimate keeps up when
/// you actually move. The first fix is taken as-is.
class GpsSmoother {
  GpsSmoother({this.walkingNoiseMps = 3.0, this.minAccuracyMeters = 3.0});

  /// How fast the true position may drift between fixes (m/s).
  final double walkingNoiseMps;

  /// Floor for reported accuracy (some devices report 0 or tiny values).
  final double minAccuracyMeters;

  double? _lat;
  double? _lng;
  double _variance = -1; // m², negative = no estimate yet
  DateTime? _lastTime;

  bool get hasEstimate => _variance >= 0;

  void reset() {
    _lat = null;
    _lng = null;
    _variance = -1;
    _lastTime = null;
  }

  /// Feeds a raw fix and returns the smoothed position.
  LatLng filter(LatLng raw, {double accuracyMeters = 10, DateTime? time}) {
    final now = time ?? DateTime.now();
    final acc = math.max(accuracyMeters, minAccuracyMeters);
    final measurementVar = acc * acc;

    if (!hasEstimate) {
      _lat = raw.latitude;
      _lng = raw.longitude;
      _variance = measurementVar;
      _lastTime = now;
      return raw;
    }

    final dt = now.difference(_lastTime!).inMilliseconds / 1000.0;
    if (dt > 0) {
      _variance += dt * walkingNoiseMps * walkingNoiseMps;
      _lastTime = now;
    }

    final k = _variance / (_variance + measurementVar);
    _lat = _lat! + k * (raw.latitude - _lat!);
    _lng = _lng! + k * (raw.longitude - _lng!);
    _variance = (1 - k) * _variance;
    return LatLng(_lat!, _lng!);
  }
}

/// Decides when the walker has really left the route (not just GPS noise).
///
/// Reroute only after staying more than [thresholdMeters] off the path for
/// [holdTime], and not again within [cooldown] of the last reroute.
class OffRouteMonitor {
  OffRouteMonitor({
    this.thresholdMeters = 30,
    this.holdTime = const Duration(seconds: 8),
    this.cooldown = const Duration(seconds: 15),
  });

  final double thresholdMeters;
  final Duration holdTime;
  final Duration cooldown;

  DateTime? _offSince;
  DateTime? _lastReroute;

  /// True while currently beyond the threshold (for UI warnings).
  bool isOff = false;

  /// Returns true when a reroute should start now.
  bool update(double offsetMeters, DateTime now) {
    isOff = offsetMeters > thresholdMeters;
    if (!isOff) {
      _offSince = null;
      return false;
    }
    _offSince ??= now;
    final coolingDown =
        _lastReroute != null && now.difference(_lastReroute!) < cooldown;
    if (!coolingDown && now.difference(_offSince!) >= holdTime) {
      _lastReroute = now;
      _offSince = null;
      return true;
    }
    return false;
  }
}
