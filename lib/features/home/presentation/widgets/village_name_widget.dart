import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VillageNameWidget extends ConsumerWidget {
  const VillageNameWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(citySettingsProvider);
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold);
    return state.when(
      loading: () => const SizedBox.shrink(),
      // Pas de repli sur un nom de ville en dur : dans une appli
      // multi-commune, ce serait potentiellement celui d'une autre commune
      // que celle du citoyen connecté.
      error: (error, stackTrace) => Text('Votre commune', style: titleStyle),
      data: (settings) => Text(settings.villageName, style: titleStyle),
    );
  }
}
