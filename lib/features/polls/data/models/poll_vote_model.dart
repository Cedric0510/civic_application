import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';

class PollVoteModel extends PollVote {
  const PollVoteModel({required super.pollId, required super.optionId});

  Map<String, dynamic> toJson() {
    return {'poll_id': pollId, 'option_id': optionId};
  }
}
