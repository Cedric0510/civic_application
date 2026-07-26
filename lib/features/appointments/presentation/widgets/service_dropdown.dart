import 'package:civic_app/features/services/presentation/controllers/services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Alimenté par les vrais services de la commune (civic_api) — un rendez-vous
// se prend désormais pour un service réel (serviceId), plus un nom de
// service tapé/choisi dans une liste figée.
class ServiceDropdown extends ConsumerWidget {
  const ServiceDropdown({super.key, required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesControllerProvider);

    return servicesAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Service',
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stackTrace) => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Service',
          border: OutlineInputBorder(),
          errorText: 'Impossible de charger les services.',
        ),
        child: SizedBox.shrink(),
      ),
      data: (services) => DropdownButtonFormField<String>(
        initialValue: null,
        decoration: const InputDecoration(
          labelText: 'Service',
          border: OutlineInputBorder(),
        ),
        items: services
            .map(
              (service) => DropdownMenuItem<String>(
                value: service.id,
                child: Text(service.name),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null ? 'Veuillez sélectionner un service.' : null,
      ),
    );
  }
}
