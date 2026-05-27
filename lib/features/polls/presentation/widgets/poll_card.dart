import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_controller.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_providers.dart';
import 'package:civic_app/features/polls/presentation/widgets/poll_option_tile.dart';
import 'package:civic_app/features/polls/presentation/widgets/poll_result_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PollCard extends ConsumerWidget {
  const PollCard({super.key, required this.poll});

  final Poll poll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votedPolls = ref.watch(votedPollsProvider);
    final hasVoted = votedPolls.containsKey(poll.id);
    final votedOptionId = votedPolls[poll.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              poll.question,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (hasVoted) ...[
              ...poll.options.map(
                (option) => PollResultBar(
                  option: option,
                  totalVotes: poll.totalVotes,
                  isSelected: option.id == votedOptionId,
                ),
              ),
              Text(
                '${poll.totalVotes} vote${poll.totalVotes != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else
              ...poll.options.map(
                (option) => PollOptionTile(
                  option: option,
                  onTap: () => ref
                      .read(pollsControllerProvider.notifier)
                      .submitVote(pollId: poll.id, optionId: option.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
