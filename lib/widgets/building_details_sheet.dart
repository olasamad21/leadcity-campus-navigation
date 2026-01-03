import 'package:flutter/material.dart';
import '../models/building.dart';
import '../theme/app_colors.dart';

/// Building details bottom sheet widget
class BuildingDetailsSheet extends StatelessWidget {
  final Building building;
  final VoidCallback? onGetDirections;
  final VoidCallback? onClose;

  const BuildingDetailsSheet({
    super.key,
    required this.building,
    this.onGetDirections,
    this.onClose,
  });

  IconData _getBuildingIcon() {
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
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: buildingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBuildingIcon(),
                  color: buildingColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: Theme.of(context).textTheme.displayMedium,
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
            ],
          ),
          
          // Description (if available)
          if (building.description != null) ...[
            const SizedBox(height: 16),
            Text(
              building.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          
          // Coordinates (optional, for debugging)
          const SizedBox(height: 16),
          Text(
            'Coordinates: ${building.entrancePoint.latitude.toStringAsFixed(6)}, ${building.entrancePoint.longitude.toStringAsFixed(6)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
          // Actions
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onGetDirections ?? () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Get Directions'),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onClose ?? () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

