import 'route_geometry.dart';
import 'map_markers.dart';

/// Direction the map should face while navigating: the general heading of
/// the next [ahead] metres of route, not the tiny segment underfoot.
///
/// Before a corner this starts turning as the corner comes within reach and
/// finishes once you are on the new leg; two quick turns blend into one.
double lookAheadBearing(RouteGeometry g, double along, {double ahead = 28}) {
  if (g.points.length < 2) return 0;
  final from = g.pointAt(along);
  final to = g.pointAt(along + ahead);
  if (RouteGeometry.distance(from, to) < 3) return g.bearingAt(along);
  return MapMarkers.bearing(from, to);
}

/// Smoothly eases the camera bearing toward a target.
///
/// * does not start rotating for changes under [deadBandDegrees] (keeps a
///   straight walk steady), but once rotating it settles fully;
/// * moves a fraction ([gain]) of the remaining angle per second-scaled step,
///   capped at [maxDegreesPerSecond] so it never whips round;
/// * always turns the short way round (e.g. 350° → 10° is +20°).
class CameraHeadingSmoother {
  CameraHeadingSmoother({
    this.deadBandDegrees = 8,
    this.settleDegrees = 1,
    this.maxDegreesPerSecond = 60,
    this.gain = 2.5,
  });

  final double deadBandDegrees;
  final double settleDegrees;
  final double maxDegreesPerSecond;

  /// Fraction of the remaining angle covered per second (exponential ease).
  final double gain;

  double bearing = 0;
  double target = 0;
  bool _rotating = false;

  bool get isRotating => _rotating;

  void reset(double b) {
    bearing = _norm(b);
    target = bearing;
    _rotating = false;
  }

  void setTarget(double t) => target = _norm(t);

  /// Advances by [dtSeconds]; returns true if the bearing changed.
  bool step(double dtSeconds) {
    final delta = diff(target, bearing);
    if (!_rotating) {
      if (delta.abs() < deadBandDegrees) return false;
      _rotating = true;
    }
    if (delta.abs() <= settleDegrees) {
      bearing = target;
      _rotating = false;
      return delta != 0;
    }
    final maxStep = maxDegreesPerSecond * dtSeconds;
    // Keep a minimum pace (15°/s) so the last few degrees don't crawl.
    final minStep = 15 * dtSeconds;
    var stepDeg = delta * (gain * dtSeconds).clamp(0.0, 1.0);
    if (stepDeg.abs() < minStep) {
      stepDeg = delta.sign * (delta.abs() < minStep ? delta.abs() : minStep);
    }
    stepDeg = stepDeg.clamp(-maxStep, maxStep);
    bearing = _norm(bearing + stepDeg);
    return true;
  }

  /// Signed shortest angle from [from] to [to], in (-180, 180].
  static double diff(double to, double from) =>
      (to - from + 540) % 360 - 180;

  static double _norm(double b) => (b % 360 + 360) % 360;
}
