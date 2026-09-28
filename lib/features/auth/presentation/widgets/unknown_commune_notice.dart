import 'package:civic_app/shared/utils/contact_launcher.dart';
import 'package:civic_app/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';

const supportEmail = 'cadarium.pro@gmail.com';

class UnknownCommuneNotice extends StatelessWidget {
  const UnknownCommuneNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Votre commune n\'est pas encore inscrite à City-Co.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InfoRow(
              icon: Icons.email_outlined,
              text: 'En cas d\'erreur, contactez le support : $supportEmail',
              onTap: () => launchEmail(supportEmail),
            ),
          ],
        ),
      ),
    );
  }
}
