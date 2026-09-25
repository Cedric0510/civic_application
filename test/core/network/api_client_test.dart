import 'dart:convert';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage([this._token]) : super();

  final String? _token;

  @override
  Future<String?> read() async => _token;
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  group('ApiClient success paths', () {
    test('GET returns the decoded JSON body', () async {
      final client = ApiClient(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'http://test.local/articles');
          return http.Response(jsonEncode({'id': '1'}), 200);
        }),
        _FakeTokenStorage(),
      );

      expect(await client.get('/articles'), {'id': '1'});
    });

    test('returns null for an empty response body (e.g. 204)', () async {
      final client = ApiClient(
        MockClient((request) async => http.Response('', 204)),
        _FakeTokenStorage(),
      );

      expect(await client.delete('/citizens/me'), isNull);
    });

    test('attaches the Authorization header when a token is stored', () async {
      String? capturedAuth;
      final client = ApiClient(
        MockClient((request) async {
          capturedAuth = request.headers['Authorization'];
          return http.Response('{}', 200);
        }),
        _FakeTokenStorage('abc123'),
      );

      await client.get('/citizens/me');

      expect(capturedAuth, 'Bearer abc123');
    });

    test('omits the Authorization header when no token is stored', () async {
      String? capturedAuth = 'unset';
      final client = ApiClient(
        MockClient((request) async {
          capturedAuth = request.headers['Authorization'];
          return http.Response('{}', 200);
        }),
        _FakeTokenStorage(),
      );

      await client.get('/articles');

      expect(capturedAuth, isNull);
    });

    test('POST encodes the body as JSON', () async {
      final client = ApiClient(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(jsonDecode(request.body), {'email': 'a@b.com'});
          return http.Response('{}', 201);
        }),
        _FakeTokenStorage(),
      );

      await client.post('/citizens/login', {'email': 'a@b.com'});
    });
  });

  group('ApiClient error mapping', () {
    test('401 throws AuthException with the server message', () async {
      final client = ApiClient(
        MockClient(
          (request) async => http.Response(
            jsonEncode({'message': 'Identifiants invalides.'}),
            401,
          ),
        ),
        _FakeTokenStorage(),
      );

      await expectLater(
        client.get('/citizens/me'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Identifiants invalides.',
          ),
        ),
      );
    });

    test('403 also throws AuthException', () async {
      final client = ApiClient(
        MockClient((request) async => http.Response('{}', 403)),
        _FakeTokenStorage(),
      );

      await expectLater(client.get('/x'), throwsA(isA<AuthException>()));
    });

    test('404 throws NotFoundException with the server message', () async {
      final client = ApiClient(
        MockClient(
          (request) async => http.Response(
            jsonEncode({'message': 'Article introuvable.'}),
            404,
          ),
        ),
        _FakeTokenStorage(),
      );

      await expectLater(
        client.get('/articles/x'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Article introuvable.',
          ),
        ),
      );
    });

    test(
      '429 throws RateLimitException with a readable message, not the raw server one',
      () async {
        final client = ApiClient(
          MockClient(
            (request) async => http.Response(
              jsonEncode({'message': 'ThrottlerException: Too Many Requests'}),
              429,
            ),
          ),
          _FakeTokenStorage(),
        );

        await expectLater(
          client.post('/citizens/forgot-password', {'email': 'a@b.com'}),
          throwsA(
            isA<RateLimitException>().having(
              (e) => e.message,
              'message',
              'Trop de tentatives. Patientez un moment avant de réessayer.',
            ),
          ),
        );
      },
    );

    test('other non-2xx statuses throw DatabaseException', () async {
      final client = ApiClient(
        MockClient((request) async => http.Response('{}', 500)),
        _FakeTokenStorage(),
      );

      await expectLater(client.get('/x'), throwsA(isA<DatabaseException>()));
    });

    test('a transport failure throws NetworkException', () async {
      final client = ApiClient(
        MockClient((request) async => throw Exception('connection refused')),
        _FakeTokenStorage(),
      );

      await expectLater(client.get('/x'), throwsA(isA<NetworkException>()));
    });

    test('joins a NestJS-style list of validation messages', () async {
      final client = ApiClient(
        MockClient(
          (request) async => http.Response(
            jsonEncode({
              'message': ['email must be an email', 'password too short'],
            }),
            400,
          ),
        ),
        _FakeTokenStorage(),
      );

      await expectLater(
        client.get('/x'),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.message,
            'message',
            'email must be an email, password too short',
          ),
        ),
      );
    });

    test('falls back to a generic message for a non-JSON error body', () async {
      final client = ApiClient(
        MockClient((request) async => http.Response('not json', 500)),
        _FakeTokenStorage(),
      );

      await expectLater(
        client.get('/x'),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.message,
            'message',
            'Une erreur est survenue.',
          ),
        ),
      );
    });
  });
}
