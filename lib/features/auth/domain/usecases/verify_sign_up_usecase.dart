import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class VerifySignUpUseCase {
  const VerifySignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String code}) =>
      _repository.verifySignUp(email: email, code: code);
}
