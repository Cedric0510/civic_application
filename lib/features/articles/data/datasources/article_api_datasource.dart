import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/articles/data/models/article_model.dart';

// Les actualités sont un contenu public côté civic_api (pas d'authentification
// requise) — voir GET /articles dans civic_api/src/articles.
class ArticleApiDatasource {
  const ArticleApiDatasource(this._api, this._communeSlug);

  final ApiClient _api;
  final String _communeSlug;

  Future<List<ArticleModel>> getArticles() async {
    final json =
        await _api.get(
              '/articles?communeSlug='
              '${Uri.encodeQueryComponent(_communeSlug)}',
            )
            as List<dynamic>;
    return json
        .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ArticleModel> getArticleById(String id) async {
    final json = await _api.get('/articles/$id') as Map<String, dynamic>;
    return ArticleModel.fromJson(json);
  }

  Future<void> recordView(String id) async {
    await _api.post('/articles/$id/view');
  }
}
