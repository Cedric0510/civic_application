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
      pollId: json['pollId'] as String,
      optionText: json['optionText'] as String,
      voteCount: json['voteCount'] as int,
    );
  }
}
