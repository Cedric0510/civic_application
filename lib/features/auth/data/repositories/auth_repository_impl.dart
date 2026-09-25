import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthApiDatasource _datasource;

  @override
  Future<void> signIn({required String email, required String password}) =>
      _datasource.signIn(email: email, password: password);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    String? invitationCode,
  }) => _datasource.signUp(
    email: email,
    password: password,
    communeSlug: communeSlug,
    invitationCode: invitationCode,
  );

  @override
  Future<void> requestPasswordReset({required String email}) =>
      _datasource.requestPasswordReset(email: email);

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _datasource.resetPassword(
    email: email,
    code: code,
    newPassword: newPassword,
  );

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<CitizenSession> changeCommune(String communeSlug) =>
      _datasource.changeCommune(communeSlug);
}
