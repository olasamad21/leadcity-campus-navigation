import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple 1D Kalman filter for smoothing GPS measurements
class KalmanFilter {
  double q; // Process noise - how much we trust movement prediction
  double r; // Measurement noise - how much we distrust raw GPS, higher = smoother
  double p; // Error covariance
  double x; // Current estimate

  KalmanFilter({
    this.q = 0.008,
    this.r = 15.0,
    this.p = 1.0,
    this.x = 0.0,
  });

  /// Apply Kalman filter formula and return smoothed value
  double filter(double measurement) {
    // Prediction update
    p = p + q;

    // Measurement update
    double k = p / (p + r); // Kalman gain
    x = x + k * (measurement - x);
    p = (1 - k) * p;

    return x;
  }
}

/// Kalman filter for LatLng coordinates
class LatLngKalmanFilter {
  final KalmanFilter _latFilter;
  final KalmanFilter _lngFilter;

  LatLngKalmanFilter({
    double q = 0.008,
    double r = 15.0,
    double p = 1.0,
  }) : _latFilter = KalmanFilter(q: q, r: r, p: p, x: 0.0),
       _lngFilter = KalmanFilter(q: q, r: r, p: p, x: 0.0);

  /// Filter raw GPS position and return smoothed LatLng
  LatLng filter(LatLng rawPosition) {
    final smoothedLat = _latFilter.filter(rawPosition.latitude);
    final smoothedLng = _lngFilter.filter(rawPosition.longitude);
    
    return LatLng(smoothedLat, smoothedLng);
  }
}
