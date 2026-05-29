import 'package:civic_app/features/services/domain/entities/service.dart';

abstract class ServiceRepository {
  Future<List<Service>> getServices();
}
