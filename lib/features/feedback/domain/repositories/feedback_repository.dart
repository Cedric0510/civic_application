import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';

abstract class FeedbackRepository {
  Future<void> send({
    required int rating,
    required FeedbackKind kind,
    required String message,
    required bool contactAllowed,
  });
}
