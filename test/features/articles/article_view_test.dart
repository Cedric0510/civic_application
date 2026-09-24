import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/articles/data/datasources/article_api_datasource.dart';
import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:civic_app/features/articles/domain/usecases/record_article_view_usecase.dart';
import 'package:civic_app/features/articles/presentation/controllers/articles_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemoryTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => 'tok';
}

class _RecordingUseCase implements RecordArticleViewUseCase {
  final recorded = <String>[];

  @override
  Future<void> call(String id) async => recorded.add(id);
}

final _article = Article(
  id: 'article-1',
  title: 'Travaux',
  content: 'Contenu',
  publishedAt: DateTime(2026, 9, 24),
);

ArticleApiDatasource _datasource(
  Future<http.Response> Function(http.Request request) handler,
) => ArticleApiDatasource(
  ApiClient(MockClient(handler), _MemoryTokenStorage()),
  'bessan',
);

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  group('ArticleApiDatasource.recordView', () {
    test('POSTs to the article view route with the citizen token', () async {
      late http.Request sent;
      final datasource = _datasource((request) async {
        sent = request;
        return http.Response('', 204);
      });

      await datasource.recordView('article-1');

      expect(sent.method, 'POST');
      expect(sent.url.path, '/articles/article-1/view');
      expect(sent.headers['Authorization'], 'Bearer tok');
    });

    test('surfaces an article that no longer exists', () async {
      final datasource = _datasource(
        (request) async =>
            http.Response('{"message":"Article introuvable."}', 404),
      );

      expect(datasource.recordView('gone'), throwsA(isA<NotFoundException>()));
    });
  });

  group('articleViewProvider', () {
    late _RecordingUseCase useCase;

    ProviderContainer containerWith(
      Future<Article> Function(String id) loadArticle,
    ) {
      useCase = _RecordingUseCase();
      final container = ProviderContainer(
        overrides: [
          articleDetailProvider.overrideWith((ref, id) => loadArticle(id)),
          recordArticleViewUseCaseProvider.overrideWithValue(useCase),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('records the view once the article has loaded', () async {
      final container = containerWith((id) async => _article);

      await container.read(articleViewProvider('article-1').future);

      expect(useCase.recorded, ['article-1']);
    });

    test('records a single view however often the page rebuilds', () async {
      final container = containerWith((id) async => _article);
      container.listen(articleViewProvider('article-1'), (_, _) {});

      await container.read(articleViewProvider('article-1').future);
      await container.read(articleViewProvider('article-1').future);
      container.read(articleViewProvider('article-1'));

      expect(useCase.recorded, ['article-1']);
    });

    test('records nothing when the article cannot be loaded', () async {
      final container = containerWith(
        (id) async => throw const NetworkException(),
      );

      await expectLater(
        container.read(articleViewProvider('article-1').future),
        throwsA(isA<NetworkException>()),
      );

      expect(useCase.recorded, isEmpty);
    });
  });
}
