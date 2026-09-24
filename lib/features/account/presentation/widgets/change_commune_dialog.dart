import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/widgets/commune_picker_field.dart';
import 'package:flutter/material.dart';

Future<CommuneRef?> showChangeCommuneDialog(
  BuildContext context, {
  required CommuneRef current,
}) {
  return showDialog<CommuneRef>(
    context: context,
    builder: (context) => _ChangeCommuneDialog(current: current),
  );
}

class _ChangeCommuneDialog extends StatefulWidget {
  const _ChangeCommuneDialog({required this.current});

  final CommuneRef current;

  @override
  State<_ChangeCommuneDialog> createState() => _ChangeCommuneDialogState();
}

class _ChangeCommuneDialogState extends State<_ChangeCommuneDialog> {
  CommuneRef? _selected;

  bool get _canConfirm =>
      _selected != null && _selected!.slug != widget.current.slug;

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
            CommunePickerField(
              value: _selected,
              onChanged: (value) => setState(() => _selected = value),
            ),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _canConfirm
              ? () => Navigator.of(context).pop(_selected)
              : null,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
