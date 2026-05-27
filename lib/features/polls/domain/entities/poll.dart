import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:equatable/equatable.dart';

class Poll extends Equatable {
  const Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.isActive,
  });

  final String id;
  final String question;
  final List<PollOption> options;
  final bool isActive;

  int get totalVotes => options.fold(0, (sum, o) => sum + o.voteCount);

  @override
  List<Object?> get props => [id, question, options, isActive];
}
