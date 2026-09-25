import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';
import 'package:civic_app/features/feedback/domain/usecases/send_feedback_usecase.dart';
import 'package:civic_app/features/feedback/presentation/controllers/feedback_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackController extends StateNotifier<AsyncValue<void>> {
  FeedbackController(this._send) : super(const AsyncData(null));

  final SendFeedbackUseCase _send;

  Future<bool> send({
    required int rating,
    required FeedbackKind kind,
    required String message,
    required bool contactAllowed,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _send(
        rating: rating,
        kind: kind,
        message: message,
        contactAllowed: contactAllowed,
      ),
    );
    return !state.hasError;
  }
}

final feedbackControllerProvider =
    StateNotifierProvider.autoDispose<FeedbackController, AsyncValue<void>>(
      (ref) => FeedbackController(ref.watch(sendFeedbackUseCaseProvider)),
    );
