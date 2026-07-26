import 'dart:convert';

import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/articles/data/models/article_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Les actualités sont un contenu public côté civic_api (pas d'authentification
// requise) — voir GET /articles dans civic_api/src/articles.
class ArticleApiDatasource {
  const ArticleApiDatasource(this._client);

  final http.Client _client;

  String get _baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:4000');

  Future<List<ArticleModel>> getArticles() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/articles'
        '?communeSlug=${Uri.encodeQueryComponent(AppConstants.communeSlug)}',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw const DatabaseException();
      }
      final json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  Future<ArticleModel> getArticleById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/articles/$id');
      final response = await _client.get(uri);
      if (response.statusCode == 404) {
        throw const NotFoundException();
      }
      if (response.statusCode != 200) {
        throw const DatabaseException();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ArticleModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
