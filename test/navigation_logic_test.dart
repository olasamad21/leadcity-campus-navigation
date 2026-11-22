import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leadcity_navigation/models/building.dart';
import 'package:leadcity_navigation/services/kalman_filter_service.dart';
import 'package:leadcity_navigation/services/places_store.dart';
import 'package:leadcity_navigation/utils/route_geometry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GpsSmoother', () {
    const home = LatLng(7.3266, 3.8800);
    final t0 = DateTime(2026, 1, 1, 12);

    test('first fix is returned unchanged', () {
      final s = GpsSmoother();
      expect(s.filter(home, accuracyMeters: 10, time: t0), home);
    });

    test('a noisy jump is damped, a precise fix is trusted', () {
      // ~55 m north of home.
      const jump = LatLng(7.3271, 3.8800);

      final noisy = GpsSmoother()..filter(home, accuracyMeters: 5, time: t0);
      final damped = noisy.filter(jump,
          accuracyMeters: 60, time: t0.add(const Duration(seconds: 1)));
      expect(RouteGeometry.distance(home, damped), lessThan(10));

      final precise = GpsSmoother()..filter(home, accuracyMeters: 30, time: t0);
      final trusted = precise.filter(jump,
          accuracyMeters: 3, time: t0.add(const Duration(seconds: 1)));
      expect(RouteGeometry.distance(jump, trusted), lessThan(5));
    });

    test('keeps up with steady walking', () {
      final s = GpsSmoother();
      var out = home;
      for (var i = 0; i <= 30; i++) {
        // 1.4 m/s north, one fix per second.
        final p = LatLng(home.latitude + i * 1.4 / 111320, home.longitude);
        out = s.filter(p, accuracyMeters: 8, time: t0.add(Duration(seconds: i)));
      }
      final truth = LatLng(home.latitude + 30 * 1.4 / 111320, home.longitude);
      expect(RouteGeometry.distance(out, truth), lessThan(6));
    });
  });

  group('OffRouteMonitor', () {
    final t0 = DateTime(2026, 1, 1, 12);

    test('ignores short GPS spikes', () {
      final m = OffRouteMonitor();
      expect(m.update(50, t0), isFalse);
      expect(m.update(50, t0.add(const Duration(seconds: 4))), isFalse);
      expect(m.update(5, t0.add(const Duration(seconds: 5))), isFalse);
      expect(m.update(50, t0.add(const Duration(seconds: 9))), isFalse);
    });

    test('reroutes after staying off the path, then cools down', () {
      final m = OffRouteMonitor();
      expect(m.update(40, t0), isFalse);
      expect(m.isOff, isTrue);
      expect(m.update(40, t0.add(const Duration(seconds: 8))), isTrue);
      // Still off right after: cooldown prevents a reroute storm.
      expect(m.update(40, t0.add(const Duration(seconds: 12))), isFalse);
      expect(m.update(40, t0.add(const Duration(seconds: 17))), isFalse);
      expect(m.update(40, t0.add(const Duration(seconds: 25))), isTrue);
    });
  });

  group('PlacesStore', () {
    Building b(String id) => Building(
          id: id,
          name: id,
          type: 'Hostel',
          entrancePoint: const LatLng(7.32, 3.88),
          polygonCoordinates: const [],
        );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PlacesStore.instance.load();
      await PlacesStore.instance.clearRecents();
    });

    test('recents are newest-first, unique and capped', () async {
      final store = PlacesStore.instance;
      for (var i = 0; i < 8; i++) {
        await store.addRecent(b('p$i'));
      }
      await store.addRecent(b('p3'));
      expect(store.recentIds.value.first, 'p3');
      expect(store.recentIds.value.length, PlacesStore.maxRecents);
      expect(store.recentIds.value.where((id) => id == 'p3').length, 1);
    });

    test('GPS placeholder is never stored', () async {
      await PlacesStore.instance.addRecent(b('__gps_current_location'));
      expect(PlacesStore.instance.recentIds.value, isEmpty);
    });

    test('favourites toggle and persist', () async {
      final store = PlacesStore.instance;
      expect(await store.toggleFavorite(b('library')), isTrue);
      expect(store.isFavorite(b('library')), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_places'), ['library']);

      expect(await store.toggleFavorite(b('library')), isFalse);
      expect(store.isFavorite(b('library')), isFalse);
    });
  });
}
