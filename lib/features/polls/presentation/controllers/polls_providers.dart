import 'package:civic_app/core/providers/supabase_provider.dart';
import 'package:civic_app/features/polls/data/datasources/poll_supabase_datasource.dart';
import 'package:civic_app/features/polls/data/repositories/poll_repository_impl.dart';
import 'package:civic_app/features/polls/domain/repositories/poll_repository.dart';
import 'package:civic_app/features/polls/domain/usecases/get_active_polls_usecase.dart';
import 'package:civic_app/features/polls/domain/usecases/submit_vote_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pollDatasourceProvider = Provider<PollSupabaseDatasource>((ref) {
  return PollSupabaseDatasource(ref.watch(supabaseClientProvider));
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

final votedPollsProvider = StateProvider<Map<String, String>>((ref) => {});
