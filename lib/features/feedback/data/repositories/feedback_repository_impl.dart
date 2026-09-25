import 'package:civic_app/features/feedback/data/datasources/feedback_api_datasource.dart';
import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';
import 'package:civic_app/features/feedback/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl(this._datasource);

  final FeedbackApiDatasource _datasource;

  @override
  Future<void> send({
    required int rating,
    required FeedbackKind kind,
    required String message,
    required bool contactAllowed,
  }) => _datasource.send(
    rating: rating,
    kind: kind,
    message: message,
    contactAllowed: contactAllowed,
  );
}
