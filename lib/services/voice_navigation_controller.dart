import 'dart:async';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/campus_graph.dart';
import '../utils/route_geometry.dart';
import 'voice_service.dart';

/// Spoken turn-by-turn guidance along a solved [CampusRoute].
///
/// Turns come from the route's shape ([detectTurns]) and prompts are driven
/// by distance walked ALONG the route ([onProgress]), so a corner is
/// announced exactly when you reach it, in the right direction, whichever
/// way the path is walked.
///
/// Two cues per turn:
///  * approach — "In 40 metres, turn left" (35–45 m before the corner), only
///    when the previous corner is far enough back for it to make sense;
///  * now — "Turn left now" (within 15 m of the corner).
class VoiceNavigationController {
  VoiceNavigationController(
    CampusRoute route,
    this._voiceService, {
    List<TurnStep>? steps,
  }) : steps = List.unmodifiable(
          steps ?? detectTurns(RouteGeometry(route.polylinePoints)),
        );

  final VoiceService _voiceService;

  /// Corners on this route, in walking order.
  final List<TurnStep> steps;

  static const double nowMeters = 15;
  static const double approachMin = 35;
  static const double approachMax = 45;

  /// Minimum gap after the previous corner before an approach cue is useful.
  static const double approachGap = 50;

  final Set<int> _announcedApproach = {};
  final Set<int> _announcedNow = {};
  bool _hasAnnouncedArrival = false;

  /// Feed the distance walked along the route (metres from its start).
  void onProgress(double alongMeters) {
    for (var i = 0; i < steps.length; i++) {
      if (_announcedNow.contains(i)) continue;
      final ahead = steps[i].alongMeters - alongMeters;

      // Walked past without a cue (e.g. GPS jump): mark done silently.
      if (ahead < -nowMeters) {
        _announcedApproach.add(i);
        _announcedNow.add(i);
        continue;
      }

      if (ahead <= nowMeters) {
        _announcedApproach.add(i);
        _announcedNow.add(i);
        unawaited(_voiceService.speak(nowPhrase(steps[i])));
        return; // one prompt per update
      }

      if (ahead >= approachMin &&
          ahead <= approachMax &&
          !_announcedApproach.contains(i) &&
          _gapBefore(i) >= approachGap) {
        _announcedApproach.add(i);
        unawaited(_voiceService.speak(approachPhrase(steps[i], ahead)));
        return;
      }
      // Later corners are further away; nothing more to say this update.
      if (ahead > approachMax) return;
    }
  }

  double _gapBefore(int i) =>
      i == 0 ? steps[0].alongMeters : steps[i].alongMeters - steps[i - 1].alongMeters;

  static String nowPhrase(TurnStep s) {
    final a = s.spokenAction;
    return '${a[0].toUpperCase()}${a.substring(1)} now';
  }

  static String approachPhrase(TurnStep s, double metres) =>
      'In ${(metres / 5).round() * 5} metres, ${s.spokenAction}';

  /// Short lead-in for the start of a route when the first corner is close.
  String? firstTurnHint() {
    if (steps.isEmpty) return null;
    final first = steps.first;
    // Too close: the "now" cue fires straight away instead.
    if (first.alongMeters > 60 || first.alongMeters <= nowMeters + 5) {
      return null;
    }
    final m = math.max(5, (first.alongMeters / 5).round() * 5);
    return 'In $m metres, ${first.spokenAction}.';
  }

  /// True when within 15 m of [destination]; speaks arrival once.
  bool checkArrival(LatLng currentPosition, LatLng destination) {
    final arrived =
        haversineDistanceMetersAnchor(currentPosition, destination) <= 15.0;
    if (arrived && !_hasAnnouncedArrival) {
      _hasAnnouncedArrival = true;
      unawaited(_voiceService.speak('You have arrived at your destination.'));
    }
    return arrived;
  }

  void reset() {
    _announcedApproach.clear();
    _announcedNow.clear();
    _hasAnnouncedArrival = false;
  }

  /// Index of the next corner whose "now" cue has not fired yet.
  int get nextInstructionIndex {
    for (var i = 0; i < steps.length; i++) {
      if (!_announcedNow.contains(i)) return i;
    }
    return steps.length;
  }

  String? get nextInstructionText {
    final i = nextInstructionIndex;
    return i < steps.length ? steps[i].instruction : null;
  }

  /// Haversine distance in metres.
  static double haversineDistanceMetersAnchor(LatLng a, LatLng b) =>
      RouteGeometry.distance(a, b);
}
