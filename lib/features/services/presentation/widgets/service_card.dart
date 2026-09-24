import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:civic_app/shared/utils/contact_launcher.dart';
import 'package:civic_app/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});

  final Service service;

  static const Color _accentColor = Color(0xFFFB8C00);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.imageUrl != null)
            Image.network(
              service.imageUrl!,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey.shade400,
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
                        service.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (service.category != null)
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
                          service.category!,
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
                if (service.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    service.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
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
