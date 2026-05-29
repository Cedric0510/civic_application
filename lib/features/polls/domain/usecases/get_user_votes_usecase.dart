import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';

class GetUserVotesUseCase {
  const GetUserVotesUseCase(this._repository);

  final PollRepository _repository;

  Future<Map<String, String>> call() => _repository.getUserVotes();
}
