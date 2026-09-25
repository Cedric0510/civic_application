import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/feedback/data/datasources/feedback_api_datasource.dart';
import 'package:civic_app/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:civic_app/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:civic_app/features/feedback/domain/usecases/send_feedback_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackDatasourceProvider = Provider<FeedbackApiDatasource>((ref) {
  return FeedbackApiDatasource(ref.watch(apiClientProvider));
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepositoryImpl(ref.watch(feedbackDatasourceProvider));
});

final sendFeedbackUseCaseProvider = Provider<SendFeedbackUseCase>((ref) {
  return SendFeedbackUseCase(ref.watch(feedbackRepositoryProvider));
});
