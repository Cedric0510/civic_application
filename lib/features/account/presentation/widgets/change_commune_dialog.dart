import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/widgets/postal_code_commune_lookup.dart';
import 'package:civic_app/features/auth/presentation/widgets/unknown_commune_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<CommuneRef?> showChangeCommuneDialog(
  BuildContext context, {
  required CommuneRef current,
}) {
  return showDialog<CommuneRef>(
    context: context,
    builder: (context) => _ChangeCommuneDialog(current: current),
  );
}

class _ChangeCommuneDialog extends ConsumerStatefulWidget {
  const _ChangeCommuneDialog({required this.current});

  final CommuneRef current;

  @override
  ConsumerState<_ChangeCommuneDialog> createState() =>
      _ChangeCommuneDialogState();
}

class _ChangeCommuneDialogState extends ConsumerState<_ChangeCommuneDialog>
    with PostalCodeCommuneLookup<_ChangeCommuneDialog> {
  final _postalCodeController = TextEditingController();
  bool _resolving = false;

  @override
  void dispose() {
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  String mapCommuneLookupError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  Future<void> _confirm() async {
    setState(() => _resolving = true);
    final commune = await resolveCommuneByPostalCode(
      _postalCodeController.text,
    );
    if (!mounted) return;
    setState(() => _resolving = false);
    if (commune == null) return;
    if (commune.slug == widget.current.slug) {
      tellCommuneLookup('Vous êtes déjà rattaché à cette commune.');
      return;
    }
    Navigator.of(context).pop(commune);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Changer de commune'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commune actuelle : ${widget.current.name}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Code postal',
                helperText:
                    'Sert à retrouver votre nouvelle commune partenaire.',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              autocorrect: false,
              onChanged: (_) {
                if (communeNotFound) setState(() => communeNotFound = false);
              },
            ),
            if (communeNotFound) ...[
              const SizedBox(height: 4),
              const UnknownCommuneNotice(),
            ],
            const SizedBox(height: 8),
            Text(
              'Par mesure anti-fraude, vous ne pourrez pas voter aux sondages '
              'de votre nouvelle commune pendant une semaine.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resolving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _resolving ? null : _confirm,
          child: _resolving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: 'Chargement en cours',
                  ),
                )
              : const Text('Confirmer'),
        ),
      ],
    );
  }
}
