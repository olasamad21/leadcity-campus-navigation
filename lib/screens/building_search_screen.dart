import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/buildings_data.dart';
import '../models/building.dart';
import '../models/building_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/building_search.dart';
import '../widgets/building_card.dart';
import '../widgets/premium/motion.dart';
import '../widgets/premium/pressable_scale.dart';

/// Full-screen picker. Pops with the chosen [Building], or with
/// [BuildingSearchScreen.currentLocation] when "Your location" is tapped.
class BuildingSearchScreen extends StatefulWidget {
  const BuildingSearchScreen({
    super.key,
    this.title = 'Search',
    this.hint = 'Search buildings, hostels, food…',
    this.allowCurrentLocation = false,
    this.excludeId,
  });

  final String title;
  final String hint;
  final bool allowCurrentLocation;

  /// Hide this building (e.g. the other end of the route).
  final String? excludeId;

  /// Sentinel result meaning "use my GPS position".
  static final Building currentLocation = Building(
    id: '__current_location',
    name: 'Your location',
    type: 'Other',
    entrancePoint: const LatLng(0, 0),
    polygonCoordinates: const [],
  );

  static bool isCurrentLocation(Building? b) => b?.id == currentLocation.id;

  @override
  State<BuildingSearchScreen> createState() => _BuildingSearchScreenState();
}

class _BuildingSearchScreenState extends State<BuildingSearchScreen> {
  final _controller = TextEditingController();
  late final List<Building> _all;
  BuildingCategory? _category;

  @override
  void initState() {
    super.initState();
    _all = BuildingsData.getAllBuildings()
        .where((b) => b.id != widget.excludeId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Building> get _results {
    final pool = _category == null
        ? _all
        : _all.where((b) => b.category == _category).toList();
    return searchBuildings(pool, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final results = _results;
    final query = _controller.text.trim();
    final categories = BuildingCategory.values
        .where((c) => _all.any((b) => b.category == c))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Hero(
                      tag: 'search-field',
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) {
                            if (results.isNotEmpty) {
                              Navigator.pop(context, results.first);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: _controller.clear,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: AppSpace.page,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final c in categories)
                    _FilterChip(
                      label: c.pluralLabel,
                      icon: c.icon,
                      color: c.color,
                      selected: _category == c,
                      onTap: () => setState(
                        () => _category = _category == c ? null : c,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                child: ListView(
                  key: ValueKey('$query|$_category'),
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    if (widget.allowCurrentLocation && query.isEmpty)
                      _CurrentLocationTile(
                        onTap: () => Navigator.pop(
                          context,
                          BuildingSearchScreen.currentLocation,
                        ),
                      ).fadeSlideIn(),
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 64),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: cs.outline),
                            const SizedBox(height: AppSpace.md),
                            Text('No places match "$query"',
                                style: text.titleMedium),
                            const SizedBox(height: 4),
                            Text('Try a shorter name or a type like "hostel"',
                                style: text.bodySmall),
                          ],
                        ).fadeSlideIn(),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                        child: Text(
                          query.isEmpty
                              ? '${results.length} places'
                              : '${results.length} results',
                          style: text.labelMedium,
                        ),
                      ),
                      for (var i = 0; i < results.length; i++)
                        BuildingCard(
                          building: results[i],
                          highlight: query,
                          onTap: () => Navigator.pop(context, results[i]),
                        ).fadeSlideIn(index: i < 12 ? i : 12, rise: 0.08),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentLocationTile extends StatelessWidget {
  const _CurrentLocationTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.route.withValues(alpha: 0.08),
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.route.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.route.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: AppColors.route),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your location', style: text.titleMedium),
                    Text('Start from where you are now (GPS)',
                        style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpace.xs),
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? (color ?? AppColors.primary) : cs.surface,
            borderRadius: AppRadius.pillAll,
            border: Border.all(
              color: selected ? Colors.transparent : cs.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? fg : color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontSize: 13, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Public so other screens (directory, map) use the same chip.
class CategoryFilterChip extends _FilterChip {
  const CategoryFilterChip({
    super.key,
    required super.label,
    required super.selected,
    required super.onTap,
    super.icon,
    super.color,
  });
}
