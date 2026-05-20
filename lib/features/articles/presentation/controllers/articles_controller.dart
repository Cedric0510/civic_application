import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:civic_app/features/articles/presentation/controllers/articles_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticlesController extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() {
    return ref.read(getArticlesUseCaseProvider)();
  }
}

final articlesControllerProvider =
    AsyncNotifierProvider<ArticlesController, List<Article>>(
      ArticlesController.new,
    );
