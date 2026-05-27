import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';

abstract class PollRepository {
  Future<List<Poll>> getActivePolls();
  Future<void> submitVote(PollVote vote);
}
