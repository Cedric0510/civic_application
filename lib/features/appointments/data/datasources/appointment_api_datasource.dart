import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_request_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_slot_model.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';
import 'package:intl/intl.dart';

class AppointmentApiDatasource {
  const AppointmentApiDatasource(this._api);

  final ApiClient _api;

  Future<void> createAppointment(AppointmentRequestModel model) async {
    await _api.post('/appointments', model.toJson());
  }

  Future<List<AppointmentModel>> getMyAppointments() async {
    final json = await _api.get('/appointments/mine') as List<dynamic>;
    return json
        .map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppointmentSlotModel>> getSlots(SlotsQuery query) async {
    final day = DateFormat('yyyy-MM-dd');
    final json =
        await _api.get(
              '/appointments/slots'
              '?serviceId=${Uri.encodeQueryComponent(query.serviceId)}'
              '&from=${day.format(query.from)}'
              '&to=${day.format(query.to)}',
            )
            as List<dynamic>;
    return json
        .map(
          (item) => AppointmentSlotModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
