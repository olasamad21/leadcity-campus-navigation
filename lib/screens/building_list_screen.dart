import 'package:flutter/material.dart';
import '../models/building.dart';
import '../widgets/building_card.dart';
import '../widgets/building_details_sheet.dart';
import '../widgets/search_field.dart';
import '../data/buildings_data.dart';
import 'find_route_screen.dart';

/// Building list screen with searchable list of all buildings
class BuildingListScreen extends StatefulWidget {
  const BuildingListScreen({super.key});

  @override
  State<BuildingListScreen> createState() => _BuildingListScreenState();
}

class _BuildingListScreenState extends State<BuildingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Building> _filteredBuildings = [];
  List<Building> _allBuildings = [];

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _searchController.addListener(_filterBuildings);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBuildings);
    _searchController.dispose();
    super.dispose();
  }

  void _loadBuildings() {
    _allBuildings = BuildingsData.getAllBuildings();
    _filteredBuildings = _allBuildings;
  }

  void _filterBuildings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBuildings = _allBuildings;
      } else {
        _filteredBuildings = _allBuildings
            .where((building) =>
                building.name.toLowerCase().contains(query) ||
                building.type.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _showBuildingDetails(Building building) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuildingDetailsSheet(
        building: building,
        onGetDirections: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FindRouteScreen(
                initialDestination: building,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Infrastructure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus on search field
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              controller: _searchController,
              hintText: 'Search buildings...',
              prefixIcon: Icons.search,
              suggestions: _allBuildings.map((b) => b.name).toList(),
              onSuggestionSelected: (suggestion) {
                final building = _allBuildings.firstWhere(
                  (b) => b.name == suggestion,
                );
                _showBuildingDetails(building);
              },
            ),
          ),
          // Building List
          Expanded(
            child: _filteredBuildings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No buildings found',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBuildings.length,
                    itemBuilder: (context, index) {
                      final building = _filteredBuildings[index];
                      return BuildingCard(
                        building: building,
                        onTap: () => _showBuildingDetails(building),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

