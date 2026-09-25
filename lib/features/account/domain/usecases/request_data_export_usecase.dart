import 'package:civic_app/features/account/domain/repositories/account_repository.dart';

class RequestDataExportUseCase {
  const RequestDataExportUseCase(this._repository);

  final AccountRepository _repository;

  Future<void> call() => _repository.requestDataExport();
}
