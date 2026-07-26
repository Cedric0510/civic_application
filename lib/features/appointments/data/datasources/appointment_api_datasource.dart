import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';

class AppointmentApiDatasource {
  const AppointmentApiDatasource(this._api);

  final ApiClient _api;

  Future<void> createAppointment(AppointmentModel model) async {
    await _api.post('/appointments', model.toJson());
  }

  Future<List<AppointmentModel>> getMyAppointments() async {
    final json = await _api.get('/appointments/mine') as List<dynamic>;
    return json
        .map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
