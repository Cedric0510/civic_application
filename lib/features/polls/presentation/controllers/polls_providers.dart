import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/polls/data/datasources/poll_api_datasource.dart';
import 'package:civic_app/features/polls/data/repositories/poll_repository_impl.dart';
import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';
import 'package:civic_app/features/polls/domain/usecases/get_active_polls_usecase.dart';
import 'package:civic_app/features/polls/domain/usecases/get_user_votes_usecase.dart';
import 'package:civic_app/features/polls/domain/usecases/submit_vote_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pollDatasourceProvider = Provider<PollApiDatasource>((ref) {
  return PollApiDatasource(
    ref.watch(apiClientProvider),
    ref.watch(authStateProvider).valueOrNull!.slug,
  );
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return PollRepositoryImpl(ref.watch(pollDatasourceProvider));
});

final getActivePollsUseCaseProvider = Provider<GetActivePollsUseCase>((ref) {
  return GetActivePollsUseCase(ref.watch(pollRepositoryProvider));
});

final submitVoteUseCaseProvider = Provider<SubmitVoteUseCase>((ref) {
  return SubmitVoteUseCase(ref.watch(pollRepositoryProvider));
});

final getUserVotesUseCaseProvider = Provider<GetUserVotesUseCase>((ref) {
  return GetUserVotesUseCase(ref.watch(pollRepositoryProvider));
});

final votedPollsProvider = StateProvider<Map<String, String>>((ref) => {});
