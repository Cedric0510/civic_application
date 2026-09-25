import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';

class FeedbackApiDatasource {
  const FeedbackApiDatasource(this._api);

  final ApiClient _api;

  Future<void> send({
    required int rating,
    required FeedbackKind kind,
    required String message,
    required bool contactAllowed,
  }) async {
    await _api.post('/feedback', {
      'rating': rating,
      'kind': kind.apiValue,
      'message': message,
      'contactAllowed': contactAllowed,
    });
  }
}
