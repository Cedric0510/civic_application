import 'package:civic_app/features/account/data/datasources/account_supabase_datasource.dart';
import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._datasource);

  final AccountSupabaseDatasource _datasource;

  @override
  Future<UserProfile?> getProfile() => _datasource.getProfile();

  @override
  Future<void> updateCity(String city) => _datasource.updateCity(city);

  @override
  Future<void> deleteAccount() => _datasource.deleteAccount();

  @override
  Future<List<Appointment>> getUserAppointments(String email) =>
      _datasource.getUserAppointments(email);
}
