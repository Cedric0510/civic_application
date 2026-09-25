import 'package:civic_app/core/auth/token_storage.dart';

class NoTokenStorage extends TokenStorage {
  NoTokenStorage() : super();

  @override
  Future<String?> read() async => null;
}
