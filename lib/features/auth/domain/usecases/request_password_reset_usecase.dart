import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) =>
      _repository.requestPasswordReset(email: email);
}
