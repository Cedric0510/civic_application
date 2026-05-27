import 'package:civic_app/core/constants/supabase_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentSupabaseDatasource {
  const AppointmentSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<void> createAppointment(AppointmentModel model) async {
    try {
      await _client
          .from(SupabaseConstants.appointmentsTable)
          .insert(model.toJson());
    } catch (_) {
      throw const DatabaseException();
    }
  }
}
