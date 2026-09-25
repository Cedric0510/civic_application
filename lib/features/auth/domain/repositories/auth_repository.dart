import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  });
  Future<void> verifySignUp({required String email, required String code});
  Future<SignUpNeedsVerification> resendSignUpCode({required String email});
  Future<void> requestPasswordReset({required String email});
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> signOut();
  Future<CitizenSession> changeCommune(String communeSlug);
}
