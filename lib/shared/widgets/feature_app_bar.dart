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
  });

  final String title;
  final Color color;
  final String backPath;
  final double expandedHeight;
  final Widget? background;

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
        background: background ?? ColoredBox(color: color),
      ),
    );
  }
}
