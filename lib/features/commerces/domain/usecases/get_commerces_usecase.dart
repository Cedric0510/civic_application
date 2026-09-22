import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';

class GetCommercesUseCase {
  const GetCommercesUseCase(this._repository);

  final CommerceRepository _repository;

  Future<List<Commerce>> call() => _repository.getCommerces();
}
