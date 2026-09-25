import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<SignUpOutcome> call({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) => _repository.signUp(
    email: email,
    password: password,
    communeSlug: communeSlug,
    acceptedTerms: acceptedTerms,
    invitationCode: invitationCode,
  );
}
