import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';
import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_controller.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePollRepository implements PollRepository {
  List<Poll> polls = const [];
  Map<String, String> userVotes = const {};
  Object? submitVoteError;
  PollVote? lastSubmittedVote;

  @override
  Future<List<Poll>> getActivePolls() async => polls;

  @override
  Future<Map<String, String>> getUserVotes() async => userVotes;

  @override
  Future<void> submitVote(PollVote vote) async {
    lastSubmittedVote = vote;
    if (submitVoteError != null) throw submitVoteError!;
  }
}

Poll _poll(String id) => Poll(
  id: id,
  question: 'Question $id',
  isActive: true,
  options: [
    PollOption(id: '$id-opt-1', pollId: id, optionText: 'Oui', voteCount: 0),
    PollOption(id: '$id-opt-2', pollId: id, optionText: 'Non', voteCount: 0),
  ],
);

void main() {
  late _FakePollRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakePollRepository()..polls = [_poll('poll-1')];
    container = ProviderContainer(
      overrides: [pollRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);
    // pollsControllerProvider is not .autoDispose, and build() must not run
    // until each test has finished configuring fakeRepo -- no eager listen
    // here.
  });

  test(
    'build() loads the active polls and seeds votedPollsProvider from the server',
    () async {
      fakeRepo.userVotes = {'poll-1': 'poll-1-opt-1'};

      final result = await container.read(pollsControllerProvider.future);

      expect(result, [_poll('poll-1')]);
      expect(container.read(votedPollsProvider), {'poll-1': 'poll-1-opt-1'});
    },
  );

  test(
    'submitVote optimistically records the vote before the server confirms it',
    () async {
      await container.read(pollsControllerProvider.future);
      // submitVote() runs synchronously up to its first `await` (the actual
      // network call), so the optimistic update is already applied to
      // votedPollsProvider the instant this call returns a Future -- no need
      // to wait for the fake repository to resolve.
      final future = container
          .read(pollsControllerProvider.notifier)
          .submitVote(pollId: 'poll-1', optionId: 'poll-1-opt-2');

      expect(
        container.read(votedPollsProvider),
        containsPair('poll-1', 'poll-1-opt-2'),
      );
      await future;
    },
  );

  test(
    'submitVote keeps the optimistic vote once the server confirms it',
    () async {
      await container.read(pollsControllerProvider.future);

      await container
          .read(pollsControllerProvider.notifier)
          .submitVote(pollId: 'poll-1', optionId: 'poll-1-opt-2');

      expect(
        container.read(votedPollsProvider),
        containsPair('poll-1', 'poll-1-opt-2'),
      );
      expect(
        fakeRepo.lastSubmittedVote,
        const PollVote(pollId: 'poll-1', optionId: 'poll-1-opt-2'),
      );
    },
  );

  test(
    'submitVote rolls back the optimistic vote when the server rejects it',
    () async {
      fakeRepo.userVotes = {'poll-1': 'poll-1-opt-1'};
      await container.read(pollsControllerProvider.future);
      expect(container.read(votedPollsProvider), {'poll-1': 'poll-1-opt-1'});

      fakeRepo.submitVoteError = Exception('Vous avez déjà voté à ce sondage.');

      await expectLater(
        container
            .read(pollsControllerProvider.notifier)
            .submitVote(pollId: 'poll-1', optionId: 'poll-1-opt-2'),
        throwsException,
      );

      // Rolled back to the vote the server actually had on record, not left
      // showing the rejected optimistic guess.
      expect(container.read(votedPollsProvider), {'poll-1': 'poll-1-opt-1'});
    },
  );

  test(
    'submitVote rollback restores "no vote" when there was none before',
    () async {
      fakeRepo.userVotes = {};
      await container.read(pollsControllerProvider.future);
      fakeRepo.submitVoteError = Exception('network error');

      await expectLater(
        container
            .read(pollsControllerProvider.notifier)
            .submitVote(pollId: 'poll-1', optionId: 'poll-1-opt-1'),
        throwsException,
      );

      expect(container.read(votedPollsProvider), isEmpty);
    },
  );
}
