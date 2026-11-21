import 'package:flutter/material.dart';

import '../models/building.dart';
import '../screens/find_route_screen.dart';
import '../screens/map_screen.dart';
import '../theme/app_tokens.dart';
import 'category_icon.dart';
import 'premium/gradient_button.dart';
import 'premium/motion.dart';

/// Opens the building sheet with sensible default actions:
/// "Get directions" → Find Route with this destination,
/// "Show on map" → campus map focused on this building.
Future<void> showBuildingDetailsSheet(
  BuildContext context,
  Building building, {
  VoidCallback? onGetDirections,
  VoidCallback? onShowOnMap,
  bool showMapAction = true,
}) {
  final navigator = Navigator.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) => BuildingDetailsSheet(
      building: building,
      onGetDirections: () {
        Navigator.pop(sheetContext);
        if (onGetDirections != null) {
          onGetDirections();
        } else {
          navigator.push(MaterialPageRoute(
            builder: (_) => FindRouteScreen(initialDestination: building),
          ));
        }
      },
      onShowOnMap: !showMapAction
          ? null
          : () {
              Navigator.pop(sheetContext);
              if (onShowOnMap != null) {
                onShowOnMap();
              } else {
                navigator.push(MaterialPageRoute(
                  builder: (_) => MapScreen(focusBuilding: building),
                ));
              }
            },
      onClose: () => Navigator.pop(sheetContext),
    ),
  );
}

/// Building details bottom sheet.
class BuildingDetailsSheet extends StatelessWidget {
  final Building building;
  final VoidCallback? onGetDirections;
  final VoidCallback? onShowOnMap;
  final VoidCallback? onClose;

  const BuildingDetailsSheet({
    super.key,
    required this.building,
    this.onGetDirections,
    this.onShowOnMap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = building.category;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.sheet,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: AppRadius.pillAll,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              CategoryIcon(category: category, size: 64).popIn(),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(building.name, style: text.displayMedium),
                    const SizedBox(height: 6),
                    CategoryLabel(category: category),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose ?? () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                ),
                tooltip: 'Close',
              ),
            ],
          ).fadeSlideIn(),
          if (building.description != null) ...[
            const SizedBox(height: AppSpace.md),
            Text(building.description!, style: text.bodyMedium)
                .fadeSlideIn(index: 1),
          ],
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              _InfoPill(
                icon: Icons.door_front_door_outlined,
                label: 'Entrance mapped',
              ),
              const SizedBox(width: AppSpace.xs),
              _InfoPill(
                icon: Icons.directions_walk_rounded,
                label: 'Walking route',
              ),
            ],
          ).fadeSlideIn(index: 1),
          const SizedBox(height: AppSpace.lg),
          GradientButton(
            label: 'Get directions',
            icon: Icons.directions_rounded,
            onPressed: onGetDirections ?? () => Navigator.pop(context),
          ).fadeSlideIn(index: 2),
          if (onShowOnMap != null) ...[
            const SizedBox(height: AppSpace.sm),
            OutlinedButton.icon(
              onPressed: onShowOnMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Show on map'),
            ).fadeSlideIn(index: 3),
          ],
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
