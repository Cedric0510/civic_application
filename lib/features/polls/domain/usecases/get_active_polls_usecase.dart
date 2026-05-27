import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';

class GetActivePollsUseCase {
  const GetActivePollsUseCase(this._repository);

  final PollRepository _repository;

  Future<List<Poll>> call() => _repository.getActivePolls();
}
