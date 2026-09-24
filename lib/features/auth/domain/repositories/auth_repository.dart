import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
  });
  Future<void> signOut();
  Future<CitizenSession> changeCommune(String communeSlug);
}
