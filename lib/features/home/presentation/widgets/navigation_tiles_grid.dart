import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationTilesGrid extends StatelessWidget {
  const NavigationTilesGrid({super.key});

  static const List<_TileData> _tiles = [
    _TileData(
      label: 'Actualités',
      icon: Icons.article_outlined,
      color: Color(0xFF1E88E5),
      path: '/articles',
    ),
    _TileData(
      label: 'Rendez-vous',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFE53935),
      path: '/appointments',
    ),
    _TileData(
      label: 'Sondages',
      icon: Icons.poll_outlined,
      color: Color(0xFF43A047),
      path: '/polls',
    ),
    _TileData(
      label: 'Services',
      icon: Icons.location_city_outlined,
      color: Color(0xFFFB8C00),
      path: '/home',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: _tiles.map((tile) => _NavigationTile(data: tile)).toList(),
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
  });

  final String label;
  final IconData icon;
  final Color color;
  final String path;
}
