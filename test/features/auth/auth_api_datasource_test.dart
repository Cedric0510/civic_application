import 'dart:convert';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _InMemoryTokenStorage extends TokenStorage {
  _InMemoryTokenStorage({String? token}) : _token = token, super();

  String? _token;
  Map<String, dynamic>? _commune;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async {
    _token = null;
    _commune = null;
  }

  @override
  Future<void> saveCommune(Map<String, String> commune) async {
    _commune = commune;
  }

  @override
  Future<Map<String, dynamic>?> readCommune() async => _commune;
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  group('AuthApiDatasource.fetchSession', () {
    test('parses role USER with no managed commerce', () async {
      final storage = _InMemoryTokenStorage(token: 'tok');
      final datasource = AuthApiDatasource(
        ApiClient(
          MockClient(
            (request) async => http.Response(
              jsonEncode({
                'role': 'USER',
                'managedCommerce': null,
                'commune': {
                  'id': 'commune-1',
                  'name': 'Bessan',
                  'slug': 'bessan',
                },
              }),
              200,
            ),
          ),
          storage,
        ),
        storage,
      );

      final session = await datasource.fetchSession();

      expect(session, isNotNull);
      expect(session!.role, CitizenRole.user);
      expect(session.managedCommerce, isNull);
      expect(session.commune.slug, 'bessan');
      expect(session.isCommercant, isFalse);
    });

    test('parses role COMMERCANT with the managed commerce', () async {
      final storage = _InMemoryTokenStorage(token: 'tok');
      final datasource = AuthApiDatasource(
        ApiClient(
          MockClient(
            (request) async => http.Response(
              jsonEncode({
                'role': 'COMMERCANT',
                'managedCommerce': {
                  'id': 'commerce-1',
                  'name': 'Boulangerie du Centre',
                },
                'commune': {
                  'id': 'commune-1',
                  'name': 'Bessan',
                  'slug': 'bessan',
                },
              }),
              200,
            ),
          ),
          storage,
        ),
        storage,
      );

      final session = await datasource.fetchSession();

      expect(session!.role, CitizenRole.commercant);
      expect(session.managedCommerce?.id, 'commerce-1');
      expect(session.managedCommerce?.name, 'Boulangerie du Centre');
      expect(session.isCommercant, isTrue);
    });

    test(
      'falls back to the cached commune (as USER) on a network failure, without logging out',
      () async {
        final storage = _InMemoryTokenStorage(token: 'tok');
        await storage.saveCommune({
          'id': 'commune-1',
          'name': 'Bessan',
          'slug': 'bessan',
        });
        final datasource = AuthApiDatasource(
          ApiClient(
            MockClient((request) async => throw Exception('network down')),
            storage,
          ),
          storage,
        );

        final session = await datasource.fetchSession();

        expect(session, isNotNull);
        expect(session!.commune.slug, 'bessan');
        expect(session.role, CitizenRole.user);
        expect(await storage.read(), 'tok');
      },
    );

    test(
      'returns null and clears the stored token on a genuine auth rejection',
      () async {
        final storage = _InMemoryTokenStorage(token: 'stale-token');
        final datasource = AuthApiDatasource(
          ApiClient(
            MockClient(
              (request) async =>
                  http.Response(jsonEncode({'message': 'Unauthorized'}), 401),
            ),
            storage,
          ),
          storage,
        );

        final session = await datasource.fetchSession();

        expect(session, isNull);
        expect(await storage.read(), isNull);
      },
    );
  });
}
