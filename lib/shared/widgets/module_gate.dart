import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModuleGate extends ConsumerWidget {
  const ModuleGate({super.key, required this.module, required this.child});

  final AppModule module;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(moduleEnabledProvider(module))
        ? child
        : const SizedBox.shrink();
  }
}
