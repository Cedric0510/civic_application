import 'package:civic_app/features/accessibility/domain/entities/display_settings.dart';
import 'package:civic_app/features/accessibility/presentation/controllers/display_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComfortModeTile extends ConsumerWidget {
  const ComfortModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabled = ref.watch(displaySettingsProvider).comfortMode;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        secondary: const Icon(Icons.text_increase),
        title: const Text(
          comfortModeName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(comfortModeDescription),
        value: enabled,
        onChanged: (value) =>
            ref.read(displaySettingsProvider.notifier).setComfortMode(value),
      ),
    );
  }
}
