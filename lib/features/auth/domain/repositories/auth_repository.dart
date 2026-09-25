import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  });
  Future<void> requestPasswordReset({required String email});
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> signOut();
  Future<CitizenSession> changeCommune(String communeSlug);
}
