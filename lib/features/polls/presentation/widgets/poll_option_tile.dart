import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:flutter/material.dart';

class PollOptionTile extends StatelessWidget {
  const PollOptionTile({
    super.key,
    required this.option,
    required this.onTap,
    this.enabled = true,
  });

  final PollOption option;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  size: 20,
                  color: enabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.optionText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled ? null : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
