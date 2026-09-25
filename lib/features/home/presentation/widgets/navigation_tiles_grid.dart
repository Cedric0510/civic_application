import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/features/accessibility/presentation/comfort_text_scale.dart';
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
      color: FeatureColors.articles,
      path: '/articles',
      module: AppModule.articles,
    ),
    _TileData(
      label: 'Rendez-vous',
      icon: Icons.calendar_month_outlined,
      color: FeatureColors.appointments,
      path: '/appointments',
      module: AppModule.appointments,
    ),
    _TileData(
      label: 'Sondages',
      icon: Icons.poll_outlined,
      color: FeatureColors.polls,
      path: '/polls',
      module: AppModule.polls,
    ),
    _TileData(
      label: 'Services',
      icon: Icons.location_city_outlined,
      color: FeatureColors.services,
      path: '/services',
      module: AppModule.services,
    ),
    _TileData(
      label: 'Commerçants',
      icon: Icons.storefront_outlined,
      color: FeatureColors.commerces,
      path: '/commerces',
      module: AppModule.commerces,
    ),
    _TileData(
      label: 'Signalements',
      icon: Icons.report_problem_outlined,
      color: FeatureColors.reports,
      path: '/reports',
      module: AppModule.reports,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = ref.watch(disabledModulesProvider);
    final large = usesLargeText(context);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: large ? 1 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: large ? 84 * scale : 120,
      ),
      children: _tiles
          .where((tile) => !disabled.contains(tile.module))
          .map((tile) => _NavigationTile(data: tile, wide: large))
          .toList(),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.data, required this.wide});

  final _TileData data;
  final bool wide;

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
          child: wide
              ? Row(
                  children: [
                    Icon(data.icon, color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Expanded(child: _label(context)),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(data.icon, color: Colors.white, size: 32),
                    _label(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context) {
    return Text(
      data.label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
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
