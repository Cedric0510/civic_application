import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class ResendSignUpCodeUseCase {
  const ResendSignUpCodeUseCase(this._repository);

  final AuthRepository _repository;

  Future<SignUpNeedsVerification> call({required String email}) =>
      _repository.resendSignUpCode(email: email);
}
