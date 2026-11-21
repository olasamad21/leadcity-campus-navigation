import 'package:flutter_test/flutter_test.dart';

import 'package:leadcity_navigation/data/campus_graph.dart';
import 'package:leadcity_navigation/services/campus_routing_service.dart';
import 'package:leadcity_navigation/services/kml_parser_service.dart';

/// The point-only places must be reachable on the real campus graph.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Campus Entrance and Enterprise route to the Library', () async {
    final buildings = await KmlParserService()
        .parseKmlFile('assets/Lead City University Campus Map.kml');
    final routing = CampusRoutingService(campusGraph);
    final library = buildings.firstWhere((b) => b.name == 'Library');

    for (final name in ['Campus Entrance', 'Enterprise']) {
      final place = buildings.firstWhere((b) => b.name == name);
      final route =
          routing.calculateRoute(place.entrancePoint, library.entrancePoint);
      expect(route, isNotNull, reason: 'no route from $name');
      expect(route!.totalDistanceMeters, greaterThan(0));
      // ignore: avoid_print
      print('$name -> Library: ${route.totalDistanceMeters.round()} m, '
          'snapped to ${route.nodeIds.first}');
    }
  });
}
