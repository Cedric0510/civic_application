import 'package:civic_app/features/polls/domain/entities/poll_vote.dart';

class PollVoteModel extends PollVote {
  const PollVoteModel({required super.pollId, required super.optionId});

  // pollId part dans l'URL (POST /polls/:id/vote), pas dans le corps —
  // civic_api dérive le citizenId du JWT.
  Map<String, dynamic> toJson() {
    return {'optionId': optionId};
  }
}
