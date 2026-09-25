import 'dart:convert';

import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/commerces/data/datasources/commerce_team_api_datasource.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/no_token_storage.dart';

CommerceTeamApiDatasource _datasource(
  Future<http.Response> Function(http.Request request) handler,
) =>
    CommerceTeamApiDatasource(ApiClient(MockClient(handler), NoTokenStorage()));

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  group('CommerceTeamApiDatasource', () {
    test(
      'reads the members and the pending invitations of the commerce',
      () async {
        final paths = <String>[];
        final datasource = _datasource((request) async {
          paths.add('${request.method} ${request.url.path}');
          if (request.url.path.endsWith('/managers')) {
            return _json([
              {'id': 'm1', 'email': 'chef@boulangerie.fr', 'isChief': true},
              {'id': 'm2', 'email': 'paul@boulangerie.fr', 'isChief': false},
            ]);
          }
          return _json([
            {
              'id': 'i1',
              'email': 'nouvelle@boulangerie.fr',
              'sentAt': '2026-09-25T10:00:00.000Z',
              'expiresAt': '2026-10-09T10:00:00.000Z',
            },
          ]);
        });

        final team = await datasource.getTeam('shop-1');

        expect(paths, [
          'GET /commerces/shop-1/managers',
          'GET /commerces/shop-1/invitations',
        ]);
        expect(team.members.map((m) => m.isChief), [true, false]);
        expect(team.members.first.email, 'chef@boulangerie.fr');
        expect(team.invitations.single.email, 'nouvelle@boulangerie.fr');
        expect(
          team.invitations.single.expiresAt,
          DateTime.parse('2026-10-09T10:00:00.000Z'),
        );
      },
    );

    test('tells a linked account from an invited address', () async {
      Map<String, dynamic>? sent;
      final datasource = _datasource((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        final linked = sent!['email'] == 'existant@boulangerie.fr';
        return _json({'status': linked ? 'linked' : 'invited'}, 201);
      });

      expect(
        await datasource.addMember('shop-1', 'existant@boulangerie.fr'),
        TeamAddOutcome.linked,
      );
      expect(
        await datasource.addMember('shop-1', 'inconnu@boulangerie.fr'),
        TeamAddOutcome.invited,
      );
      expect(sent, {'email': 'inconnu@boulangerie.fr'});
    });

    test(
      'removes a member and withdraws an invitation of this commerce',
      () async {
        final calls = <String>[];
        final datasource = _datasource((request) async {
          calls.add('${request.method} ${request.url.path}');
          return http.Response('', 204);
        });

        await datasource.removeMember('shop-1', 'm2');
        await datasource.cancelInvitation('shop-1', 'i1');

        expect(calls, [
          'DELETE /commerces/shop-1/managers/m2',
          'DELETE /commerces/shop-1/invitations/i1',
        ]);
      },
    );

    test(
      'surfaces the refusal of a collaborator who is not the chief',
      () async {
        final datasource = _datasource(
          (_) async => _json({
            'message': 'Seul le chef du commerce peut gérer l\'équipe.',
          }, 403),
        );

        await expectLater(
          datasource.getTeam('shop-1'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Seul le chef du commerce peut gérer l\'équipe.',
            ),
          ),
        );
      },
    );
  });

  group('ManagedCommerceRef', () {
    test('is the chief only when the server says so', () {
      expect(
        ManagedCommerceRef.fromJson({
          'id': 'shop-1',
          'name': 'Boulangerie',
          'isChief': true,
        }).isChief,
        isTrue,
      );
      expect(
        ManagedCommerceRef.fromJson({
          'id': 'shop-1',
          'name': 'Boulangerie',
          'isChief': false,
        }).isChief,
        isFalse,
      );
    });

    test('is not the chief when an older server sends no information', () {
      expect(
        ManagedCommerceRef.fromJson({
          'id': 'shop-1',
          'name': 'Boulangerie',
        }).isChief,
        isFalse,
      );
    });
  });
}
