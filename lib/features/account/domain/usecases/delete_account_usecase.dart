import 'package:civic_app/features/account/domain/repositories/account_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final AccountRepository _repository;

  Future<void> call() => _repository.deleteAccount();
}
