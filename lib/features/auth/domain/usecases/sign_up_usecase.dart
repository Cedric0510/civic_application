import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String password,
    required String communeSlug,
    String? invitationCode,
  }) => _repository.signUp(
    email: email,
    password: password,
    communeSlug: communeSlug,
    invitationCode: invitationCode,
  );
}
