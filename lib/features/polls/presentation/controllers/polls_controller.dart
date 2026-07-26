import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PollsController extends AsyncNotifier<List<Poll>> {
  @override
  Future<List<Poll>> build() async {
    final polls = await ref.read(getActivePollsUseCaseProvider)();
    final votes = await ref.read(getUserVotesUseCaseProvider)();
    ref.read(votedPollsProvider.notifier).state = votes;
    return polls;
  }

  Future<void> submitVote({
    required String pollId,
    required String optionId,
  }) async {
    final previousVotes = ref.read(votedPollsProvider);
    ref
        .read(votedPollsProvider.notifier)
        .update((state) => {...state, pollId: optionId});
    try {
      await ref.read(submitVoteUseCaseProvider)(
        PollVote(pollId: pollId, optionId: optionId),
      );
      ref.invalidateSelf();
    } catch (_) {
      // Le vote a échoué (pas connecté, déjà voté...) : on annule la mise à
      // jour optimiste pour ne pas afficher un vote qui n'a pas eu lieu.
      ref.read(votedPollsProvider.notifier).state = previousVotes;
      rethrow;
    }
  }
}

final pollsControllerProvider =
    AsyncNotifierProvider<PollsController, List<Poll>>(PollsController.new);
