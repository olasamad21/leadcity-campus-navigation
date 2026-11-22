import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/building.dart';
import '../services/places_store.dart';
import '../theme/app_colors.dart';

/// Heart toggle that saves a place; pops when saved.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.building});

  final Building building;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<String>>(
      valueListenable: PlacesStore.instance.favoriteIds,
      builder: (context, ids, _) {
        final saved = ids.contains(building.id);
        final icon = Icon(
          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: saved ? AppColors.error : cs.onSurfaceVariant,
        );
        return IconButton(
          tooltip: saved ? 'Remove from saved' : 'Save place',
          style: IconButton.styleFrom(
            backgroundColor: saved
                ? AppColors.error.withValues(alpha: 0.12)
                : cs.surfaceContainerHighest,
          ),
          onPressed: () async {
            HapticFeedback.lightImpact();
            final nowSaved =
                await PlacesStore.instance.toggleFavorite(building);
            if (!context.mounted) return;
            ScaffoldMessenger.maybeOf(context)
              ?..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                duration: const Duration(seconds: 2),
                content: Text(nowSaved
                    ? '${building.name} saved'
                    : '${building.name} removed from saved'),
              ));
          },
          icon: saved
              ? icon
                  .animate(key: const ValueKey('saved'))
                  .scaleXY(begin: 0.4, end: 1, curve: Curves.elasticOut, duration: 600.ms)
              : icon,
        );
      },
    );
  }
}
