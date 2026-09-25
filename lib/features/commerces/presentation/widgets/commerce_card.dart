import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/shared/utils/contact_launcher.dart';
import 'package:civic_app/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';

class CommerceCard extends StatelessWidget {
  const CommerceCard({super.key, required this.commerce});

  final Commerce commerce;

  static const Color _accentColor = Color(0xFF00897B);
  static const Color _notesColor = Color(0xFFFB8C00);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (commerce.imageUrl != null)
            Image.network(
              commerce.imageUrl!,
              excludeFromSemantics: true,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.outline,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        commerce.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (commerce.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          commerce.category!,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: _accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (commerce.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    commerce.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (commerce.notes != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _notesColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _notesColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          size: 18,
                          color: _notesColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            commerce.notes!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: _notesColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (commerce.phone != null ||
                    commerce.email != null ||
                    commerce.address != null ||
                    commerce.hours != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                ],
                if (commerce.phone != null)
                  InfoRow(
                    icon: Icons.phone_outlined,
                    text: commerce.phone!,
                    onTap: () => launchPhoneCall(commerce.phone!),
                  ),
                if (commerce.email != null)
                  InfoRow(
                    icon: Icons.email_outlined,
                    text: commerce.email!,
                    onTap: () => launchEmail(commerce.email!),
                  ),
                if (commerce.address != null)
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: commerce.address!,
                  ),
                if (commerce.hours != null)
                  InfoRow(
                    icon: Icons.access_time_outlined,
                    text: commerce.hours!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
