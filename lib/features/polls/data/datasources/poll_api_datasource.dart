import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/polls/data/models/poll_model.dart';
import 'package:civic_app/features/polls/data/models/poll_vote_model.dart';

class PollApiDatasource {
  const PollApiDatasource(this._api, this._communeSlug);

  final ApiClient _api;
  final String _communeSlug;

  Future<List<PollModel>> getActivePolls() async {
    final json =
        await _api.get(
              '/polls?communeSlug='
              '${Uri.encodeQueryComponent(_communeSlug)}',
            )
            as List<dynamic>;
    return json
        .map((item) => PollModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitVote(PollVoteModel model) async {
    await _api.post('/polls/${model.pollId}/vote', model.toJson());
  }

  // Silencieux par conception : un citoyen non connecté peut consulter les
  // sondages (contenu public), il n'a simplement pas de votes personnels à
  // afficher — pas d'erreur à faire remonter jusqu'à la liste des sondages.
  Future<Map<String, String>> getUserVotes() async {
    try {
      final json = await _api.get('/polls/mine/votes') as List<dynamic>;
      return {
        for (final vote in json.cast<Map<String, dynamic>>())
          vote['pollId'] as String: vote['optionId'] as String,
      };
    } catch (_) {
      return {};
    }
  }
}
