import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:flutter/material.dart';

class PollResultBar extends StatelessWidget {
  const PollResultBar({
    super.key,
    required this.option,
    required this.totalVotes,
    required this.isSelected,
  });

  final PollOption option;
  final int totalVotes;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes == 0 ? 0.0 : option.voteCount / totalVotes;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option.optionText,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : null,
                  ),
                ),
              ),
              Text(
                '${(percentage * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? colorScheme.primary : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.secondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
