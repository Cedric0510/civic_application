import 'package:civic_app/features/account/data/datasources/account_api_datasource.dart';
import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._datasource);

  final AccountApiDatasource _datasource;

  @override
  Future<UserProfile?> getProfile() => _datasource.getProfile();

  @override
  Future<void> deleteAccount() => _datasource.deleteAccount();
}
