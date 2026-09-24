import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NavigationTilesGrid extends ConsumerWidget {
  const NavigationTilesGrid({super.key});

  static const List<_TileData> _tiles = [
    _TileData(
      label: 'Actualités',
      icon: Icons.article_outlined,
      color: Color(0xFF1E88E5),
      path: '/articles',
      module: AppModule.articles,
    ),
    _TileData(
      label: 'Rendez-vous',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFE53935),
      path: '/appointments',
      module: AppModule.appointments,
    ),
    _TileData(
      label: 'Sondages',
      icon: Icons.poll_outlined,
      color: Color(0xFF43A047),
      path: '/polls',
      module: AppModule.polls,
    ),
    _TileData(
      label: 'Services',
      icon: Icons.location_city_outlined,
      color: Color(0xFFFB8C00),
      path: '/services',
      module: AppModule.services,
    ),
    _TileData(
      label: 'Commerçants',
      icon: Icons.storefront_outlined,
      color: Color(0xFF00897B),
      path: '/commerces',
      module: AppModule.commerces,
    ),
    _TileData(
      label: 'Signalements',
      icon: Icons.report_problem_outlined,
      color: Color(0xFF6D4C41),
      path: '/reports',
      module: AppModule.reports,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = ref.watch(disabledModulesProvider);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: _tiles
          .where((tile) => !disabled.contains(tile.module))
          .map((tile) => _NavigationTile(data: tile))
          .toList(),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(data.path),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(data.icon, color: Colors.white, size: 32),
              Text(
                data.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileData {
  const _TileData({
    required this.label,
    required this.icon,
    required this.color,
    required this.path,
    required this.module,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String path;
  final AppModule module;
}
