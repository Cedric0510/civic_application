import 'package:civic_app/shared/widgets/section_title.dart';
import 'package:civic_app/features/account/presentation/controllers/account_controller.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPrivacySection extends ConsumerWidget {
  const AccountPrivacySection({super.key, required this.communeSlug});

  final String communeSlug;

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recevoir mes données'),
        content: const Text(
          'Une copie de vos données (compte, rendez-vous, réponses aux '
          'sondages, signalements et avis) sera envoyée à l\'adresse e-mail '
          'de votre compte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final sent = await ref
        .read(accountControllerProvider.notifier)
        .requestDataExport();
    if (!context.mounted || !sent) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Un e-mail avec vos données vient de vous être envoyé.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Mes données et informations'),
        const SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.rate_review_outlined),
          title: const Text('Donner mon avis'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/feedback'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_outlined),
          title: const Text('Recevoir mes données par e-mail'),
          subtitle: const Text(
            'Une copie de tout ce que nous conservons sur vous.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _exportData(context, ref),
        ),
        for (final document in LegalDocument.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: Text(document.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(
              Uri(
                path: '/legal/${document.routeSegment}',
                queryParameters: {'commune': communeSlug},
              ).toString(),
            ),
          ),
      ],
    );
  }
}
