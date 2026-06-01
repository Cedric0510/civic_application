import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:civic_app/features/services/domain/repositories/service_repository.dart';

class GetServicesUseCase {
  const GetServicesUseCase(this._repository);

  final ServiceRepository _repository;

  Future<List<Service>> call() => _repository.getServices();
}
