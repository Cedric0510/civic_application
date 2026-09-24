import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountAppointmentCard extends StatelessWidget {
  const AccountAppointmentCard({super.key, required this.appointment});

  final Appointment appointment;

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.demande:
        return Colors.grey.shade600;
      case AppointmentStatus.confirme:
        return Colors.green.shade600;
      case AppointmentStatus.annule:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat(
      "dd/MM/yyyy 'à' HH:mm",
    ).format(appointment.startsAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFFE53935),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.serviceName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            appointment.status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appointment.status.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _statusColor(appointment.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: theme.textTheme.bodySmall),
                  if (appointment.message != null &&
                      appointment.message!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      appointment.message!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
