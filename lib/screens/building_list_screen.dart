import 'package:flutter/material.dart';

import '../data/buildings_data.dart';
import '../models/building.dart';
import '../models/building_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/building_search.dart';
import '../widgets/building_card.dart';
import '../widgets/building_details_sheet.dart';
import '../widgets/category_icon.dart';
import '../widgets/premium/motion.dart';
import 'building_search_screen.dart';

/// Campus directory: collapsing header, search, category filters and
/// buildings grouped by category.
class BuildingListScreen extends StatefulWidget {
  const BuildingListScreen({super.key, this.initialCategory});

  final BuildingCategory? initialCategory;

  @override
  State<BuildingListScreen> createState() => _BuildingListScreenState();
}

class _BuildingListScreenState extends State<BuildingListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  late final List<Building> _all;
  BuildingCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _all = List.of(BuildingsData.getAllBuildings())
      ..sort((a, b) => a.name.compareTo(b.name));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Building> get _filtered {
    final pool = _category == null
        ? _all
        : _all.where((b) => b.category == _category).toList();
    return searchBuildings(pool, _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final query = _searchController.text.trim();
    final results = _filtered;
    final categories = BuildingCategory.values
        .where((c) => _all.any((b) => b.category == c))
        .toList();

    // Group by category only when browsing everything without a query.
    final grouped = query.isEmpty && _category == null;
    final rows = <Widget>[];
    if (grouped) {
      var i = 0;
      for (final c in categories) {
        final items = results.where((b) => b.category == c).toList();
        if (items.isEmpty) continue;
        rows.add(_GroupHeader(category: c, count: items.length)
            .fadeSlideIn(index: i < 10 ? i : 10));
        for (final b in items) {
          rows.add(_card(b, query).fadeSlideIn(index: i < 10 ? i : 10));
          i++;
        }
      }
    } else {
      for (var i = 0; i < results.length; i++) {
        rows.add(_card(results[i], query)
            .fadeSlideIn(index: i < 12 ? i : 12, rise: 0.08));
      }
    }

    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _searchFocus.requestFocus(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 16,
              ),
              title: Text(
                'Directory',
                style: text.titleLarge?.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.brandGradient),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Text(
                  '${_all.length} places',
                  style: text.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by name or type',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _searchController.clear,
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: AppSpace.page,
                children: [
                  CategoryFilterChip(
                    label: 'All',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final c in categories)
                    CategoryFilterChip(
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xs)),
          if (results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 56, color: cs.outline),
                    const SizedBox(height: AppSpace.md),
                    Text('No buildings found', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text('Try a different name or category',
                        style: text.bodySmall),
                  ],
                ).fadeSlideIn(),
              ),
            )
          else
            SliverList.list(
              key: ValueKey('$query|$_category'),
              children: rows,
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _card(Building b, String query) => BuildingCard(
        building: b,
        highlight: query,
        onTap: () => showBuildingDetailsSheet(context, b),
      );
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.category, required this.count});

  final BuildingCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Row(
        children: [
          CategoryIcon(category: category, size: 28),
          const SizedBox(width: AppSpace.xs + 2),
          Text(category.pluralLabel, style: text.titleMedium),
          const SizedBox(width: AppSpace.xs),
          Text('$count', style: text.bodySmall),
        ],
      ),
    );
  }
}
