import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:civic_app/features/articles/domain/repositories/article_repository.dart';

class GetArticleByIdUseCase {
  const GetArticleByIdUseCase(this._repository);

  final ArticleRepository _repository;

  Future<Article> call(String id) => _repository.getArticleById(id);
}
