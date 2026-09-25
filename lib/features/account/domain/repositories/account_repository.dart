import 'package:civic_app/features/account/domain/entities/user_profile.dart';

abstract class AccountRepository {
  Future<UserProfile?> getProfile();
  Future<void> deleteAccount();
  Future<void> requestDataExport();
}
