import 'package:flutter/material.dart';

import '../models/building.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'category_icon.dart';
import 'premium/pressable_scale.dart';

/// Directory row: category tile, name, category label, chevron.
class BuildingCard extends StatelessWidget {
  final Building building;
  final VoidCallback? onTap;

  /// Characters to emphasise in the name (current search query).
  final String highlight;

  const BuildingCard({
    super.key,
    required this.building,
    this.onTap,
    this.highlight = '',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = building.category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              CategoryIcon(category: category, size: 48),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightedText(
                      text: building.name,
                      query: highlight,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    CategoryLabel(category: category),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text with the first case-insensitive match of [query] emphasised.
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
  });

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final start = q.isEmpty ? -1 : text.toLowerCase().indexOf(q);
    if (start < 0) {
      return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final end = start + q.length;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.accent
                  : AppColors.primary,
              fontWeight: FontWeight.w800,
              backgroundColor: AppColors.accent.withValues(alpha: 0.18),
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
