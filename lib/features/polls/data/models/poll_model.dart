import 'package:civic_app/features/polls/data/models/poll_option_model.dart';
import 'package:civic_app/features/polls/domain/entities/poll.dart';

class PollModel extends Poll {
  const PollModel({
    required super.id,
    required super.question,
    required super.options,
    required super.isActive,
    super.opensAt,
    super.closesAt,
    super.isVotable,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List<dynamic>;
    return PollModel(
      id: json['id'] as String,
      question: json['question'] as String,
      isActive: json['isActive'] as bool,
      opensAt: json['opensAt'] != null
          ? DateTime.parse(json['opensAt'] as String)
          : null,
      closesAt: json['closesAt'] != null
          ? DateTime.parse(json['closesAt'] as String)
          : null,
      isVotable: json['isVotable'] as bool? ?? true,
      options: optionsList
          .map((o) => PollOptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}
