import 'package:civic_app/core/errors/app_exception.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseDatasource {
  const AuthSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    } catch (_) {
      throw const app_errors.AuthException();
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    } catch (_) {
      throw const app_errors.AuthException();
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      throw const app_errors.AuthException();
    }
  }
}
