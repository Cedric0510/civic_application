import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {}

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<CitizenSession> changeCommune(String communeSlug) =>
      throw UnimplementedError();
}
