import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';

class UpdateCommerceUseCase {
  const UpdateCommerceUseCase(this._repository);

  final CommerceRepository _repository;

  Future<void> call(Commerce commerce) => _repository.updateCommerce(commerce);
}
