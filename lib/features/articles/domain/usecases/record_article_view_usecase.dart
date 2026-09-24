import 'package:civic_app/features/articles/domain/repositories/article_repository.dart';

class RecordArticleViewUseCase {
  const RecordArticleViewUseCase(this._repository);

  final ArticleRepository _repository;

  Future<void> call(String id) => _repository.recordView(id);
}
