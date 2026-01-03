import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'find_route_screen.dart';
import 'map_screen.dart';
import 'building_list_screen.dart';

/// Home screen with primary action cards
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToFindRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FindRouteScreen()),
    );
  }

  void _navigateToMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  void _navigateToBuildingList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BuildingListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead City Navigation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Welcome message
              Text(
                'Welcome to Lead City University',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 32),
              // Find Route Card
              _ActionCard(
                icon: Icons.route,
                title: 'Find Route',
                subtitle: 'Navigate between buildings',
                onTap: () => _navigateToFindRoute(context),
              ),
              const SizedBox(height: 16),
              // View Map Card
              _ActionCard(
                icon: Icons.map,
                title: 'View Map',
                subtitle: 'Explore campus buildings',
                onTap: () => _navigateToMap(context),
              ),
              const SizedBox(height: 16),
              // School Infrastructure Card
              _ActionCard(
                icon: Icons.business,
                title: 'School Infrastructure',
                subtitle: 'Browse all buildings',
                onTap: () => _navigateToBuildingList(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action card widget for home screen
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
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

