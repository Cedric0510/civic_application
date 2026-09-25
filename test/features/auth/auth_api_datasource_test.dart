import 'dart:convert';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
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

    test('parses voteEligibleAt, and leaves it null when absent', () async {
      Future<CitizenSession?> sessionFrom(Map<String, dynamic> extra) {
        final storage = _InMemoryTokenStorage(token: 'tok');
        return AuthApiDatasource(
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
                  ...extra,
                }),
                200,
              ),
            ),
            storage,
          ),
          storage,
        ).fetchSession();
      }

      final withDate = await sessionFrom({
        'voteEligibleAt': '2026-10-01T07:52:19.227Z',
      });
      final withoutDate = await sessionFrom({});

      expect(
        withDate!.voteEligibleAt,
        DateTime.parse('2026-10-01T07:52:19.227Z'),
      );
      expect(withoutDate!.voteEligibleAt, isNull);
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
      'returns null and clears the token when the response cannot be read',
      () async {
        final storage = _InMemoryTokenStorage(token: 'tok');
        final datasource = AuthApiDatasource(
          ApiClient(
            MockClient(
              (request) async =>
                  http.Response(jsonEncode({'role': 'USER'}), 200),
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

  group('AuthApiDatasource.signUp', () {
    Future<Map<String, dynamic>> bodySentBy({String? invitationCode}) async {
      final storage = _InMemoryTokenStorage();
      late Map<String, dynamic> sent;
      final datasource = AuthApiDatasource(
        ApiClient(
          MockClient((request) async {
            expect(request.url.path, '/citizens/signup');
            sent = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response(jsonEncode({'accessToken': 'tok'}), 201);
          }),
          storage,
        ),
        storage,
      );

      await datasource.signUp(
        email: 'martine@boulangerie.fr',
        password: 'secret123',
        communeSlug: 'bessan',
        invitationCode: invitationCode,
      );
      expect(await storage.read(), 'tok');
      return sent;
    }

    test('sends the invitation code when there is one, trimmed', () async {
      final body = await bodySentBy(invitationCode: '  K7QM-2XPD ');

      expect(body['invitationCode'], 'K7QM-2XPD');
      expect(body['communeSlug'], 'bessan');
    });

    test('leaves the field out when the code is missing or blank', () async {
      expect(await bodySentBy(), isNot(contains('invitationCode')));
      expect(
        await bodySentBy(invitationCode: '   '),
        isNot(contains('invitationCode')),
      );
    });
  });

  group('AuthApiDatasource password reset', () {
    test('asks for a code with the address only', () async {
      final storage = _InMemoryTokenStorage();
      late http.Request seen;
      final datasource = AuthApiDatasource(
        ApiClient(
          MockClient((request) async {
            seen = request;
            return http.Response('', 204);
          }),
          storage,
        ),
        storage,
      );

      await datasource.requestPasswordReset(email: 'martine@example.fr');

      expect(seen.method, 'POST');
      expect(seen.url.path, '/citizens/forgot-password');
      expect(jsonDecode(seen.body), {'email': 'martine@example.fr'});
    });

    test(
      'sends the address, the code and the new password to reset it',
      () async {
        final storage = _InMemoryTokenStorage();
        late http.Request seen;
        final datasource = AuthApiDatasource(
          ApiClient(
            MockClient((request) async {
              seen = request;
              return http.Response('', 204);
            }),
            storage,
          ),
          storage,
        );

        await datasource.resetPassword(
          email: 'martine@example.fr',
          code: 'K7QM-2XPD',
          newPassword: 'nouveau-mot-de-passe',
        );

        expect(seen.url.path, '/citizens/reset-password');
        expect(jsonDecode(seen.body), {
          'email': 'martine@example.fr',
          'code': 'K7QM-2XPD',
          'newPassword': 'nouveau-mot-de-passe',
        });
      },
    );

    test(
      'does not touch the stored session: nobody is signed in by a reset',
      () async {
        final storage = _InMemoryTokenStorage(token: 'tok');
        final datasource = AuthApiDatasource(
          ApiClient(MockClient((_) async => http.Response('', 204)), storage),
          storage,
        );

        await datasource.resetPassword(
          email: 'martine@example.fr',
          code: 'K7QM-2XPD',
          newPassword: 'nouveau-mot-de-passe',
        );

        expect(await storage.read(), 'tok');
      },
    );
  });

  group('AuthApiDatasource.changeCommune', () {
    test(
      'PATCHes the chosen slug, returns the new session and caches the new commune',
      () async {
        final storage = _InMemoryTokenStorage(token: 'tok');
        late http.Request sent;
        final datasource = AuthApiDatasource(
          ApiClient(
            MockClient((request) async {
              sent = request;
              return http.Response(
                jsonEncode({
                  'role': 'USER',
                  'managedCommerce': null,
                  'voteEligibleAt': '2026-10-01T00:00:00.000Z',
                  'commune': {
                    'id': 'commune-2',
                    'name': 'Saint-Martin-de-Belleville',
                    'slug': 'saint-martin-de-belleville',
                  },
                }),
                200,
              );
            }),
            storage,
          ),
          storage,
        );

        final session = await datasource.changeCommune(
          'saint-martin-de-belleville',
        );

        expect(sent.method, 'PATCH');
        expect(sent.url.path, '/citizens/me/commune');
        expect(jsonDecode(sent.body), {
          'communeSlug': 'saint-martin-de-belleville',
        });
        expect(session.commune.slug, 'saint-martin-de-belleville');
        expect(
          session.voteEligibleAt,
          DateTime.parse('2026-10-01T00:00:00.000Z'),
        );
        expect(
          (await storage.readCommune())!['slug'],
          'saint-martin-de-belleville',
        );
      },
    );
  });

  group('CitizenSession.canVoteAt', () {
    const commune = CommuneRef(id: 'c', name: 'Bessan', slug: 'bessan');
    final eligibleAt = DateTime.utc(2026, 10, 1);

    test('is false before voteEligibleAt and true from that instant on', () {
      final session = CitizenSession(
        commune: commune,
        role: CitizenRole.user,
        voteEligibleAt: eligibleAt,
      );

      expect(session.canVoteAt(DateTime.utc(2026, 9, 30, 23, 59)), isFalse);
      expect(session.canVoteAt(eligibleAt), isTrue);
    });

    test('is true when the eligibility date is unknown (offline fallback)', () {
      const session = CitizenSession(commune: commune, role: CitizenRole.user);

      expect(session.canVoteAt(DateTime.utc(2020)), isTrue);
    });
  });
}
