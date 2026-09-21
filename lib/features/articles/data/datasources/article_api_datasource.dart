import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/articles/data/models/article_model.dart';

// Les actualités sont un contenu public côté civic_api (pas d'authentification
// requise) — voir GET /articles dans civic_api/src/articles.
class ArticleApiDatasource {
  const ArticleApiDatasource(this._api);

  final ApiClient _api;

  Future<List<ArticleModel>> getArticles() async {
    final json =
        await _api.get(
              '/articles?communeSlug='
              '${Uri.encodeQueryComponent(AppConstants.communeSlug)}',
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
}
