import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';

class GetUserProfileUseCase {
  const GetUserProfileUseCase(this._repository);

  final AccountRepository _repository;

  Future<UserProfile?> call() => _repository.getProfile();
}
