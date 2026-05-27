import 'package:civic_app/features/polls/data/datasources/poll_supabase_datasource.dart';
import 'package:civic_app/features/polls/data/models/poll_vote_model.dart';
import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';
import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';

class PollRepositoryImpl implements PollRepository {
  const PollRepositoryImpl(this._datasource);

  final PollSupabaseDatasource _datasource;

  @override
  Future<List<Poll>> getActivePolls() => _datasource.getActivePolls();

  @override
  Future<void> submitVote(PollVote vote) {
    return _datasource.submitVote(
      PollVoteModel(pollId: vote.pollId, optionId: vote.optionId),
    );
  }
}
