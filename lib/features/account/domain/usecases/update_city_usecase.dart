import 'package:civic_app/features/account/domain/repositories/account_repository.dart';

class UpdateCityUseCase {
  const UpdateCityUseCase(this._repository);

  final AccountRepository _repository;

  Future<void> call(String city) => _repository.updateCity(city);
}
