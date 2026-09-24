import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _weekdayLabels = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];

class SlotPicker extends StatefulWidget {
  const SlotPicker({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
  });

  final List<AppointmentSlot> slots;
  final AppointmentSlot? selected;
  final ValueChanged<AppointmentSlot?> onSelected;

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  DateTime? _day;

  String _dayLabel(DateTime day) =>
      '${_weekdayLabels[day.weekday - 1]} ${DateFormat('dd/MM').format(day)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = groupSlotsByDay(widget.slots);

    if (days.isEmpty) {
      return Text(
        'Aucun créneau disponible pour ce service dans les prochaines '
        'semaines.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final day = days.containsKey(_day) ? _day! : days.keys.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jour', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final candidate = days.keys.elementAt(index);
              return ChoiceChip(
                label: Text(_dayLabel(candidate)),
                selected: candidate == day,
                onSelected: (_) {
                  setState(() => _day = candidate);
                  widget.onSelected(null);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('Heure', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in days[day]!)
              ChoiceChip(
                label: Text(
                  DateFormat('HH:mm').format(slot.startsAt.toLocal()),
                ),
                selected: slot == widget.selected,
                onSelected: (_) => widget.onSelected(slot),
              ),
          ],
        ),
      ],
    );
  }
}
