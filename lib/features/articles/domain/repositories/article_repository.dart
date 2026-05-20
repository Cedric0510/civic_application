import 'package:civic_app/features/articles/domain/entities/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> getArticles();
  Future<Article> getArticleById(String id);
}
