import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:civic_app/shared/utils/contact_launcher.dart';
import 'package:civic_app/shared/widgets/category_pill.dart';
import 'package:civic_app/shared/widgets/feature_icon_avatar.dart';
import 'package:civic_app/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});

  final Service service;

  static const Color _accentColor = FeatureColors.services;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.imageUrl != null)
            Image.network(
              service.imageUrl!,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.imageUrl == null) ...[
                      const FeatureIconAvatar(
                        icon: Icons.location_city_outlined,
                        color: _accentColor,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        service.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (service.category != null) ...[
                      const SizedBox(width: 8),
                      CategoryPill(
                        label: service.category!,
                        color: _accentColor,
                      ),
                    ],
                  ],
                ),
                if (service.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    service.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (service.phone != null ||
                    service.email != null ||
                    service.address != null ||
                    service.hours != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                ],
                if (service.phone != null)
                  InfoRow(
                    icon: Icons.phone_outlined,
                    text: service.phone!,
                    onTap: () => launchPhoneCall(service.phone!),
                  ),
                if (service.email != null)
                  InfoRow(
                    icon: Icons.email_outlined,
                    text: service.email!,
                    onTap: () => launchEmail(service.email!),
                  ),
                if (service.address != null)
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: service.address!,
                  ),
                if (service.hours != null)
                  InfoRow(
                    icon: Icons.access_time_outlined,
                    text: service.hours!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
