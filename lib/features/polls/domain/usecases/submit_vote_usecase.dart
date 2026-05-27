import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';
import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';

class SubmitVoteUseCase {
  const SubmitVoteUseCase(this._repository);

  final PollRepository _repository;

  Future<void> call(PollVote vote) => _repository.submitVote(vote);
}
