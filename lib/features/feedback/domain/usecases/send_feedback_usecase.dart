import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';
import 'package:civic_app/features/feedback/domain/repositories/feedback_repository.dart';

class SendFeedbackUseCase {
  const SendFeedbackUseCase(this._repository);

  final FeedbackRepository _repository;

  Future<void> call({
    required int rating,
    required FeedbackKind kind,
    required String message,
    required bool contactAllowed,
  }) => _repository.send(
    rating: rating,
    kind: kind,
    message: message,
    contactAllowed: contactAllowed,
  );
}
