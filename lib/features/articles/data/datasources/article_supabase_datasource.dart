import 'package:civic_app/core/constants/supabase_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/articles/data/models/article_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleSupabaseDatasource {
  const ArticleSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<List<ArticleModel>> getArticles() async {
    try {
      final response = await _client
          .from(SupabaseConstants.articlesTable)
          .select()
          .order('published_at', ascending: false);
      return response.map(ArticleModel.fromJson).toList();
    } catch (_) {
      throw const DatabaseException();
    }
  }

  Future<ArticleModel> getArticleById(String id) async {
    try {
      final response = await _client
          .from(SupabaseConstants.articlesTable)
          .select()
          .eq('id', id)
          .single();
      return ArticleModel.fromJson(response);
    } catch (_) {
      throw const DatabaseException();
    }
  }
}
