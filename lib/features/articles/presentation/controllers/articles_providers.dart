import 'package:civic_app/core/providers/supabase_provider.dart';
import 'package:civic_app/features/articles/data/datasources/article_supabase_datasource.dart';
import 'package:civic_app/features/articles/data/repositories/article_repository_impl.dart';
import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:civic_app/features/articles/domain/repositories/article_repository.dart';
import 'package:civic_app/features/articles/domain/usecases/get_article_by_id_usecase.dart';
import 'package:civic_app/features/articles/domain/usecases/get_articles_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final articleDatasourceProvider = Provider<ArticleSupabaseDatasource>((ref) {
  return ArticleSupabaseDatasource(ref.watch(supabaseClientProvider));
});

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepositoryImpl(ref.watch(articleDatasourceProvider));
});

final getArticlesUseCaseProvider = Provider<GetArticlesUseCase>((ref) {
  return GetArticlesUseCase(ref.watch(articleRepositoryProvider));
});

final getArticleByIdUseCaseProvider = Provider<GetArticleByIdUseCase>((ref) {
  return GetArticleByIdUseCase(ref.watch(articleRepositoryProvider));
});

final articleDetailProvider = FutureProvider.autoDispose
    .family<Article, String>((ref, id) {
      return ref.read(getArticleByIdUseCaseProvider)(id);
    });
