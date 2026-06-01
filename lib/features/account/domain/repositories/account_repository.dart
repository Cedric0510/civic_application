import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';

abstract class AccountRepository {
  Future<UserProfile?> getProfile();
  Future<void> updateCity(String city);
  Future<void> deleteAccount();
  Future<List<Appointment>> getUserAppointments(String email);
}
