import 'package:civic_app/features/articles/data/datasources/article_supabase_datasource.dart';
import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:civic_app/features/articles/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl(this._datasource);

  final ArticleSupabaseDatasource _datasource;

  @override
  Future<List<Article>> getArticles() => _datasource.getArticles();

  @override
  Future<Article> getArticleById(String id) => _datasource.getArticleById(id);
}
