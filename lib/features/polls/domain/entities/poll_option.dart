import 'package:equatable/equatable.dart';

class PollOption extends Equatable {
  const PollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.voteCount,
  });

  final String id;
  final String pollId;
  final String optionText;
  final int voteCount;

  @override
  List<Object?> get props => [id, pollId, optionText, voteCount];
}
