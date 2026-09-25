import 'package:civic_app/features/accessibility/domain/entities/display_settings.dart';
import 'package:civic_app/features/accessibility/presentation/controllers/display_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComfortModeButton extends ConsumerWidget {
  const ComfortModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(displaySettingsProvider).comfortMode;
    return Semantics(
      toggled: enabled,
      child: IconButton(
        isSelected: enabled,
        tooltip: enabled
            ? '$comfortModeName activé : toucher pour le désactiver'
            : '$comfortModeName : agrandir les textes',
        icon: const Icon(Icons.text_increase),
        selectedIcon: const Icon(Icons.text_decrease),
        onPressed: () =>
            ref.read(displaySettingsProvider.notifier).toggleComfortMode(),
      ),
    );
  }
}
