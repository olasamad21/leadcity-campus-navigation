import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leadcity_navigation/data/buildings_data.dart';
import 'package:leadcity_navigation/models/building.dart';
import 'package:leadcity_navigation/models/building_category.dart';
import 'package:leadcity_navigation/screens/building_list_screen.dart';
import 'package:leadcity_navigation/screens/building_search_screen.dart';
import 'package:leadcity_navigation/screens/find_route_screen.dart';
import 'package:leadcity_navigation/screens/home_screen.dart';
import 'package:leadcity_navigation/services/places_store.dart';
import 'package:leadcity_navigation/theme/app_theme.dart';

/// Screens that do not embed a Google Map (maps need a real device).
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppTheme.useGoogleFonts = false;
    SharedPreferences.setMockInitialValues({});
    await BuildingsData.loadFromKml();
    await PlacesStore.instance.load();
  });

  Widget app(Widget home) => MaterialApp(theme: AppTheme.lightTheme, home: home);

  /// Lets entrance animations finish (some loops never "settle").
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('home shows the header, categories and popular places',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 2000));
    await tester.pumpWidget(app(const HomeScreen()));
    await settle(tester);

    expect(find.text('Where are you\nheading today?'), findsOneWidget);
    expect(find.text('Hostels'), findsOneWidget);
    expect(find.text('Find a route'), findsOneWidget);
    expect(find.text('Popular places'), findsOneWidget);
    expect(find.text('Library'), findsWidgets);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('directory filters by typed name', (tester) async {
    await tester.pumpWidget(app(const BuildingListScreen()));
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'peace');
    await settle(tester);

    expect(find.textContaining('Peace hall', findRichText: true), findsNWidgets(2));
    expect(find.textContaining('Library', findRichText: true), findsNothing);
  });

  testWidgets('directory opens on a chosen category', (tester) async {
    await tester.pumpWidget(
      app(const BuildingListScreen(initialCategory: BuildingCategory.religious)),
    );
    await settle(tester);

    expect(find.textContaining('Chapel', findRichText: true), findsOneWidget);
    expect(find.textContaining('Mosque', findRichText: true), findsOneWidget);
    expect(find.textContaining('Library', findRichText: true), findsNothing);
  });

  testWidgets('search ranks initials and returns the tapped place',
      (tester) async {
    Building? picked;
    await tester.pumpWidget(app(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async {
              picked = await Navigator.of(context).push<Building>(
                MaterialPageRoute(builder: (_) => const BuildingSearchScreen()),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'pg');
    await settle(tester);
    await tester.tap(find.textContaining('PG Hostel', findRichText: true).first);
    await settle(tester);

    expect(picked?.name, 'PG Hostel');
  });

  testWidgets('find route asks for a start when only the destination is set',
      (tester) async {
    final library = BuildingsData.getBuildingByName('Library')!;
    await tester.pumpWidget(app(FindRouteScreen(initialDestination: library)));
    await settle(tester);

    expect(find.text('Plan your walk'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Where are you starting from?'), findsOneWidget);
    expect(find.text('Start from my location'), findsOneWidget);
  });
}
