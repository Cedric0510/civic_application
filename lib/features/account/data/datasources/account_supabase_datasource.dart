import 'package:civic_app/core/constants/supabase_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart' as app_errors;
import 'package:civic_app/features/account/data/models/user_profile_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSupabaseDatasource {
  AccountSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<UserProfileModel?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await _client
          .from(SupabaseConstants.userProfilesTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (data == null) return null;
      return UserProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(e.message);
    }
  }

  Future<void> updateCity(String city) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const app_errors.AuthException('Non authentifié');
    try {
      await _client.from(SupabaseConstants.userProfilesTable).upsert({
        'id': user.id,
        'preferred_city': city,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(e.message);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _client.rpc('delete_user');
      await _client.auth.signOut();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(e.message);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Future<List<Appointment>> getUserAppointments(String email) async {
    try {
      final data = await _client
          .from(SupabaseConstants.appointmentsTable)
          .select()
          .eq('email', email)
          .order('date', ascending: false);
      return (data as List)
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(e.message);
    }
  }
}
