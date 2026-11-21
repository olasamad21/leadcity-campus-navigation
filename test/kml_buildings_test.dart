import 'package:flutter_test/flutter_test.dart';

import 'package:leadcity_navigation/data/building_categories.dart';
import 'package:leadcity_navigation/models/building_category.dart';
import 'package:leadcity_navigation/services/kml_parser_service.dart';

/// Checks the bundled campus KML parses into usable, uniquely named buildings.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('campus KML parses into uniquely identified buildings', () async {
    final buildings = await KmlParserService()
        .parseKmlFile('assets/Lead City University Campus Map.kml');

    expect(buildings, isNotEmpty);

    final ids = buildings.map((b) => b.id).toList();
    final duplicates =
        ids.where((id) => ids.indexOf(id) != ids.lastIndexOf(id)).toSet();
    expect(duplicates, isEmpty, reason: 'duplicate building ids: $duplicates');

    for (final b in buildings) {
      expect(b.name.trim(), b.name, reason: 'untrimmed name "${b.name}"');
      if (b.polygonCoordinates.isNotEmpty) {
        expect(b.polygonCoordinates.length, greaterThanOrEqualTo(3),
            reason: '${b.name} has a broken polygon');
      }
    }

    final names = buildings.map((b) => b.name).toSet();
    expect(names, containsAll(['Rebelation hall 1', 'Rebelation hall 2']));
  });

  test('lone entrance points become point-only places', () async {
    final buildings = await KmlParserService()
        .parseKmlFile('assets/Lead City University Campus Map.kml');

    final gate = buildings.firstWhere((b) => b.name == 'Campus Entrance');
    expect(gate.polygonCoordinates, isEmpty);
    expect(gate.category, BuildingCategory.facility);
    // Moved 20 m south of the original survey point.
    expect(gate.entrancePoint.latitude, closeTo(7.3266103, 1e-7));
    expect(gate.entrancePoint.longitude, closeTo(3.8766739, 1e-7));

    final enterprise = buildings.firstWhere((b) => b.name == 'Enterprise');
    expect(enterprise.polygonCoordinates, isEmpty);
    expect(enterprise.category, BuildingCategory.area);

    // The field keeps its own entrance; it is a different place.
    final field = buildings.firstWhere((b) => b.name == 'Enterprise field');
    expect(field.entrancePoint, isNot(enterprise.entrancePoint));

    // Stray points without a category never become places.
    expect(buildings.where((b) => b.name.startsWith('Unassigned')), isEmpty);
  });

  test('every KML building has an owner-assigned category', () async {
    final buildings = await KmlParserService()
        .parseKmlFile('assets/Lead City University Campus Map.kml');

    final missing = buildings
        .where((b) => categoryForBuildingName(b.name) == null)
        .map((b) => b.name)
        .toList();
    expect(missing, isEmpty, reason: 'no category for: $missing');

    final peace = buildings.firstWhere((b) => b.name == 'Peace hall 1');
    expect(peace.category, BuildingCategory.hostel);
    final mosque = buildings.firstWhere((b) => b.name == 'Mosque');
    expect(mosque.category, BuildingCategory.religious);
  });
}
