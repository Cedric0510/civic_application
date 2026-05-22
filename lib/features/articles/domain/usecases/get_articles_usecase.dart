import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:civic_app/features/articles/domain/repositories/article_repository.dart';

class GetArticlesUseCase {
  const GetArticlesUseCase(this._repository);

  final ArticleRepository _repository;

  Future<List<Article>> call() => _repository.getArticles();
}
