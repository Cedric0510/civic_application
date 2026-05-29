import 'package:civic_app/core/constants/supabase_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart' as app_errors;
import 'package:civic_app/features/polls/data/models/poll_model.dart';
import 'package:civic_app/features/polls/data/models/poll_vote_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PollSupabaseDatasource {
  const PollSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<List<PollModel>> getActivePolls() async {
    try {
      final response = await _client
          .from(SupabaseConstants.pollsTable)
          .select('*, ${SupabaseConstants.pollOptionsTable}(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return response.map(PollModel.fromJson).toList();
    } catch (_) {
      throw const app_errors.DatabaseException();
    }
  }

  Future<void> submitVote(PollVoteModel model) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const app_errors.AuthException();
      await _client.from(SupabaseConstants.pollVotesTable).insert({
        ...model.toJson(),
        'user_id': userId,
      });
    } on app_errors.AuthException {
      rethrow;
    } catch (_) {
      throw const app_errors.DatabaseException();
    }
  }

  Future<Map<String, String>> getUserVotes() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return {};
      final response = await _client
          .from(SupabaseConstants.pollVotesTable)
          .select('poll_id, option_id')
          .eq('user_id', userId);
      return {
        for (final row in response)
          row['poll_id'] as String: row['option_id'] as String,
      };
    } catch (_) {
      return {};
    }
  }
}
