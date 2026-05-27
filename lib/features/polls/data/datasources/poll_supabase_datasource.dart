import 'package:civic_app/core/constants/supabase_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
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
      throw const DatabaseException();
    }
  }

  Future<void> submitVote(PollVoteModel model) async {
    try {
      await _client
          .from(SupabaseConstants.pollVotesTable)
          .insert(model.toJson());
    } catch (_) {
      throw const DatabaseException();
    }
  }
}
