import 'package:civic_app/features/polls/domain/entities/poll_option.dart';

class PollOptionModel extends PollOption {
  const PollOptionModel({
    required super.id,
    required super.pollId,
    required super.optionText,
    required super.voteCount,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionText: json['option_text'] as String,
      voteCount: json['vote_count'] as int,
    );
  }
}
