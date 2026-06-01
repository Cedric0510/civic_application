import 'package:civic_app/features/services/data/datasources/service_supabase_datasource.dart';
import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:civic_app/features/services/domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  const ServiceRepositoryImpl(this._datasource);

  final ServiceSupabaseDatasource _datasource;

  @override
  Future<List<Service>> getServices() => _datasource.getServices();
}
