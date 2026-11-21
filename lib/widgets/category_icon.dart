import 'package:flutter/material.dart';

import '../models/building_category.dart';
import '../theme/app_tokens.dart';

/// Rounded tinted tile with a category icon. Pass [heroTag] to fly the tile
/// between a list row and the details sheet.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 52,
    this.heroTag,
  });

  final BuildingCategory category;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
    if (heroTag == null) return tile;
    return Hero(
      tag: heroTag!,
      child: Material(type: MaterialType.transparency, child: tile),
    );
  }
}

/// Small coloured dot + label, e.g. "● Hostel".
class CategoryLabel extends StatelessWidget {
  const CategoryLabel({super.key, required this.category});

  final BuildingCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration:
              BoxDecoration(color: category.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpace.xs - 2),
        Text(
          category.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
