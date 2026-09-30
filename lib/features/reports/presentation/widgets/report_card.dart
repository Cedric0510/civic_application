import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/shared/widgets/category_pill.dart';
import 'package:civic_app/shared/widgets/feature_icon_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});

  final Report report;

  static IconData _categoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.voirie:
        return Icons.add_road_outlined;
      case ReportCategory.eclairage:
        return Icons.lightbulb_outline;
      case ReportCategory.proprete:
        return Icons.cleaning_services_outlined;
      case ReportCategory.espacesVerts:
        return Icons.park_outlined;
      case ReportCategory.autre:
        return Icons.report_problem_outlined;
    }
  }

  Color _statusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.nouveau:
        return Colors.red.shade600;
      case ReportStatus.enCours:
        return Colors.amber.shade800;
      case ReportStatus.traite:
        return Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = report.status ?? ReportStatus.nouveau;
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeatureIconAvatar(
                  icon: _categoryIcon(report.category),
                  color: FeatureColors.reports,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.category.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CategoryPill(label: status.label, color: statusColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.address,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (report.createdAt != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy à HH:mm').format(report.createdAt!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
