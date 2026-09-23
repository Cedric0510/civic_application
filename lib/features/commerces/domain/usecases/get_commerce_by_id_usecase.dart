import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';

class GetCommerceByIdUseCase {
  const GetCommerceByIdUseCase(this._repository);

  final CommerceRepository _repository;

  Future<Commerce> call(String id) => _repository.getCommerceById(id);
}
