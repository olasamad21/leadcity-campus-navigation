import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/buildings_data.dart';
import '../models/building.dart';
import '../models/building_category.dart';
import '../services/places_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/building_details_sheet.dart';
import '../widgets/category_icon.dart';
import '../widgets/premium/motion.dart';
import '../widgets/premium/pressable_scale.dart';
import 'building_list_screen.dart';
import 'find_route_screen.dart';
import 'map_screen.dart';

/// Home: branded header with "Where to?" search, quick categories,
/// primary actions and popular places, all entering with a stagger.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _popularNames = [
    'Library',
    'Senate Building',
    'Faculty of Law',
    'Clinic',
    'Tasty Vine',
    'Stadium',
  ];

  static const _quickCategories = [
    BuildingCategory.hostel,
    BuildingCategory.academic,
    BuildingCategory.lectureRoom,
    BuildingCategory.food,
    BuildingCategory.sports,
    BuildingCategory.religious,
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final buildings = BuildingsData.getAllBuildings();
    final popular = _popularNames
        .map(BuildingsData.getBuildingByName)
        .whereType<Building>()
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                greeting: _greeting(),
                onSearch: () => _push(context, const FindRouteScreen()),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionTitle('Browse by type').fadeSlideIn(index: 2),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpace.page,
                  itemCount: _quickCategories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpace.xs),
                  itemBuilder: (context, i) {
                    final c = _quickCategories[i];
                    return _CategoryChip(
                      category: c,
                      onTap: () => _push(
                        context,
                        BuildingListScreen(initialCategory: c),
                      ),
                    ).fadeSlideIn(index: 3 + i, rise: 0.3);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionTitle('Get around').fadeSlideIn(index: 4),
            ),
            SliverPadding(
              padding: AppSpace.page,
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _FeatureCard(
                      onTap: () => _push(context, const FindRouteScreen()),
                    ).fadeSlideIn(index: 5),
                    const SizedBox(height: AppSpace.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.map_rounded,
                            title: 'Campus map',
                            subtitle: 'Explore buildings',
                            color: AppColors.route,
                            onTap: () => _push(context, const MapScreen()),
                          ).fadeSlideIn(index: 6),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.apartment_rounded,
                            title: 'Directory',
                            subtitle: '${buildings.length} places',
                            color: AppColors.residential,
                            onTap: () =>
                                _push(context, const BuildingListScreen()),
                          ).fadeSlideIn(index: 7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: PlacesStore.instance.favoriteIds,
                builder: (context, ids, _) => _PlacesRow(
                  title: 'Saved places',
                  icon: Icons.favorite_rounded,
                  buildings: PlacesStore.resolve(ids),
                  startIndex: 8,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: PlacesStore.instance.recentIds,
                builder: (context, ids, _) => _PlacesRow(
                  title: 'Recent',
                  icon: Icons.history_rounded,
                  buildings: PlacesStore.resolve(ids),
                  startIndex: 8,
                  onClear: ids.isEmpty ? null : PlacesStore.instance.clearRecents,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _PlacesRow(
                title: 'Popular places',
                buildings: popular,
                startIndex: 9,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                child: Text(
                  'Routes are calculated on your phone using the campus '
                  'walkway network.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall,
                ),
              ).fadeSlideIn(index: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.onSearch});

  final String greeting;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: 0.30),
                  AppColors.accent.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.school_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ).popIn(),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lead City University',
                              style: text.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              'Campus Navigator',
                              style: text.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).fadeSlideIn(),
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    greeting,
                    style: text.bodyLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ).fadeSlideIn(index: 1),
                  const SizedBox(height: AppSpace.xxs),
                  Text(
                    'Where are you\nheading today?',
                    style: text.displayLarge?.copyWith(color: Colors.white),
                  ).fadeSlideIn(index: 1),
                  const SizedBox(height: AppSpace.lg),
                  PressableScale(
                    onTap: onSearch,
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.mdAll,
                        boxShadow: AppShadows.raised(AppColors.primaryDeep),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AppColors.primary),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Text(
                              'Search a building or destination',
                              style: text.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: AppRadius.smAll,
                            ),
                            child: const Icon(
                              Icons.directions_walk_rounded,
                              size: 18,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).fadeSlideIn(index: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Titled horizontal row of place cards; renders nothing when empty.
class _PlacesRow extends StatelessWidget {
  const _PlacesRow({
    required this.title,
    required this.buildings,
    required this.startIndex,
    this.icon,
    this.onClear,
  });

  final String title;
  final List<Building> buildings;
  final int startIndex;
  final IconData? icon;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (buildings.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 12, 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.accent),
                const SizedBox(width: AppSpace.xs),
              ],
              Expanded(child: Text(title, style: text.titleLarge)),
              if (onClear != null)
                TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ).fadeSlideIn(index: startIndex),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpace.page,
            itemCount: buildings.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
            itemBuilder: (context, i) => _PlaceCard(
              building: buildings[i],
              onTap: () => showBuildingDetailsSheet(context, buildings[i]),
            ).fadeSlideIn(index: startIndex + 1 + i, rise: 0.2),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final BuildingCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: 6),
            Text(
              category.pluralLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 13.5,
                    color: cs.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3E7BFA), Color(0xFF2E3D77)],
          ),
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.glow(AppColors.route),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find a route',
                    style: text.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpace.xxs),
                  Text(
                    'Step-by-step walking directions with voice guidance',
                    style: text.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      'Start',
                      style: text.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(
                Icons.alt_route_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: cs.outlineVariant),
          boxShadow: AppShadows.soft(AppColors.primaryDeep),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: AppSpace.md),
            Text(title, style: text.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.building, required this.onTap});

  final Building building;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = building.category;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryIcon(category: category, size: 44),
            const Spacer(),
            Text(
              building.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium?.copyWith(fontSize: 14.5, height: 1.25),
            ),
            const SizedBox(height: 4),
            CategoryLabel(category: category),
          ],
        ),
      ),
    );
  }
}
