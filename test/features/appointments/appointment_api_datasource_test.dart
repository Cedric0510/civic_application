import 'dart:convert';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/appointments/data/datasources/appointment_api_datasource.dart';
import 'package:civic_app/features/appointments/data/models/appointment_request_model.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemoryTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => 'tok';
}

AppointmentApiDatasource _datasource(
  Future<http.Response> Function(http.Request request) handler,
) {
  return AppointmentApiDatasource(
    ApiClient(MockClient(handler), _MemoryTokenStorage()),
  );
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  test(
    'getSlots asks for the service and the local day range, and parses the slots',
    () async {
      late http.Request sent;
      final datasource = _datasource((request) async {
        sent = request;
        return http.Response(
          jsonEncode([
            {
              'startsAt': '2026-10-14T07:00:00.000Z',
              'endsAt': '2026-10-14T07:30:00.000Z',
            },
          ]),
          200,
        );
      });

      final slots = await datasource.getSlots(
        SlotsQuery(
          serviceId: 'service-1',
          from: DateTime(2026, 10, 14),
          to: DateTime(2026, 11, 13),
        ),
      );

      expect(sent.method, 'GET');
      expect(sent.url.path, '/appointments/slots');
      expect(sent.url.queryParameters, {
        'serviceId': 'service-1',
        'from': '2026-10-14',
        'to': '2026-11-13',
      });
      expect(slots, hasLength(1));
      expect(slots.single.startsAt, DateTime.parse('2026-10-14T07:00:00.000Z'));
      expect(slots.single.endsAt, DateTime.parse('2026-10-14T07:30:00.000Z'));
    },
  );

  test('createAppointment POSTs the chosen slot start', () async {
    late http.Request sent;
    final datasource = _datasource((request) async {
      sent = request;
      return http.Response('{}', 201);
    });

    await datasource.createAppointment(
      AppointmentRequestModel(
        serviceId: 'service-1',
        startsAt: DateTime.utc(2026, 10, 14, 7),
        message: 'Permis',
      ),
    );

    expect(sent.method, 'POST');
    expect(sent.url.path, '/appointments');
    expect(jsonDecode(sent.body), {
      'serviceId': 'service-1',
      'startsAt': '2026-10-14T07:00:00.000Z',
      'message': 'Permis',
    });
  });
}
