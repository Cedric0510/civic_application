import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VillageNameWidget extends ConsumerWidget {
  const VillageNameWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(citySettingsProvider);
    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => Text(
        AppConstants.villageName,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      data: (settings) => Text(
        settings.villageName,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
