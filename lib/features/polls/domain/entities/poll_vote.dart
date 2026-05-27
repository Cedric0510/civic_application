import 'package:equatable/equatable.dart';

class PollVote extends Equatable {
  const PollVote({required this.pollId, required this.optionId});

  final String pollId;
  final String optionId;

  @override
  List<Object?> get props => [pollId, optionId];
}
