import 'package:civic_app/features/polls/data/models/poll_option_model.dart';
import 'package:civic_app/features/polls/domain/entities/poll.dart';

class PollModel extends Poll {
  const PollModel({
    required super.id,
    required super.question,
    required super.options,
    required super.isActive,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final optionsList = json['poll_options'] as List<dynamic>;
    return PollModel(
      id: json['id'] as String,
      question: json['question'] as String,
      isActive: json['is_active'] as bool,
      options: optionsList
          .map((o) => PollOptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}
