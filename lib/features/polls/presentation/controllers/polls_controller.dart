import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PollsController extends AsyncNotifier<List<Poll>> {
  @override
  Future<List<Poll>> build() {
    return ref.read(getActivePollsUseCaseProvider)();
  }

  Future<void> submitVote({
    required String pollId,
    required String optionId,
  }) async {
    ref
        .read(votedPollsProvider.notifier)
        .update((state) => {...state, pollId: optionId});
    await ref.read(submitVoteUseCaseProvider)(
      PollVote(pollId: pollId, optionId: optionId),
    );
    ref.invalidateSelf();
  }
}

final pollsControllerProvider =
    AsyncNotifierProvider<PollsController, List<Poll>>(PollsController.new);
