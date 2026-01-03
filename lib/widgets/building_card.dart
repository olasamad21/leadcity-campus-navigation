import 'package:flutter/material.dart';
import '../models/building.dart';
import '../theme/app_colors.dart';

/// Reusable building card widget
class BuildingCard extends StatelessWidget {
  final Building building;
  final VoidCallback? onTap;
  final IconData? icon;

  const BuildingCard({
    super.key,
    required this.building,
    this.onTap,
    this.icon,
  });

  IconData _getBuildingIcon() {
    if (icon != null) return icon!;
    
    switch (building.type.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'administrative':
      case 'admin':
        return Icons.business;
      case 'residential':
        return Icons.home;
      case 'recreation':
      case 'dining':
      case 'recreation/dining':
        return Icons.restaurant;
      case 'medical':
        return Icons.local_hospital;
      case 'religious':
        return Icons.church;
      case 'facilities':
      case 'facility':
        return Icons.build;
      default:
        return Icons.location_city;
    }
  }

  Color _getBuildingColor() {
    return AppColors.getBuildingTypeColor(building.type);
  }

  @override
  Widget build(BuildContext context) {
    final buildingColor = _getBuildingColor();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: buildingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBuildingIcon(),
                  color: buildingColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        building.type,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: buildingColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: buildingColor),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

