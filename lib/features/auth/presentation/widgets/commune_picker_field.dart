import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sélecteur de commune à l'inscription : uniquement les communes déjà
// partenaires de City-Co (endpoint public /communes/public). Une commune
// absente de la liste n'est volontairement pas saisissable ici -- cf.
// _showCommuneNotListedDialog.
class CommunePickerField extends ConsumerWidget {
  const CommunePickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CommuneRef? value;
  final ValueChanged<CommuneRef?> onChanged;

  Future<void> _showCommuneNotListedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Votre commune n\'est pas encore partenaire'),
        content: const Text(
          'City-Co n\'est pas encore disponible pour votre commune. Nous '
          'travaillons à étendre le service à plus de villes et vous '
          'informerons dès qu\'elle rejoindra City-Co.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communesAsync = ref.watch(publicCommunesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        communesAsync.when(
          loading: () => const InputDecorator(
            decoration: InputDecoration(
              labelText: 'Commune',
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
              labelText: 'Commune',
              border: OutlineInputBorder(),
              errorText: 'Impossible de charger la liste des communes.',
            ),
            child: SizedBox.shrink(),
          ),
          data: (communes) => DropdownButtonFormField<CommuneRef>(
            initialValue: value,
            decoration: const InputDecoration(
              labelText: 'Commune',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
            ),
            items: communes
                .map(
                  (commune) => DropdownMenuItem<CommuneRef>(
                    value: commune,
                    child: Text(commune.name),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: (value) =>
                value == null ? 'Veuillez sélectionner votre commune.' : null,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _showCommuneNotListedDialog(context),
            child: const Text('Ma commune n\'est pas dans la liste ?'),
          ),
        ),
      ],
    );
  }
}
