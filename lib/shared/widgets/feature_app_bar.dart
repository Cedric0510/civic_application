import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeatureAppBar extends StatelessWidget {
  const FeatureAppBar({
    super.key,
    required this.title,
    required this.color,
    this.backPath = '/home',
    this.expandedHeight = 80,
    this.background,
    this.icon,
  });

  final String title;
  final Color color;
  final String backPath;
  final double expandedHeight;
  final Widget? background;

  // Grand pictogramme en filigrane derrière le titre : donne une identité
  // propre à chaque rubrique au lieu d'un simple bandeau de couleur unie.
  // Ignoré si `background` est fourni (ex. photo d'un article).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    return SliverAppBar(
      expandedHeight: expandedHeight * scale,
      toolbarHeight: kToolbarHeight * scale,
      pinned: true,
      backgroundColor: color,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Retour',
        onPressed: () => context.go(backPath),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
        background: background ?? _DefaultBackground(color: color, icon: icon),
      ),
    );
  }
}

class _DefaultBackground extends StatelessWidget {
  const _DefaultBackground({required this.color, required this.icon});

  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final watermarkIcon = icon;
    return ColoredBox(
      color: color,
      // Stack.hardEdge (le défaut) rogne le pictogramme aux limites de la
      // barre, d'où le débordement volontaire en Positioned négatif.
      child: watermarkIcon == null
          ? null
          : Stack(
              children: [
                Positioned(
                  right: -24,
                  bottom: -24,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Icon(
                      watermarkIcon,
                      size: 160,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
