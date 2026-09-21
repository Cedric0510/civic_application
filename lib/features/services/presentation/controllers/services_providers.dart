import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/services/data/datasources/service_api_datasource.dart';
import 'package:civic_app/features/services/data/repositories/service_repository_impl.dart';
import 'package:civic_app/features/services/domain/repositories/service_repository.dart';
import 'package:civic_app/features/services/domain/usecases/get_services_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _serviceDatasourceProvider = Provider<ServiceApiDatasource>(
  (ref) => ServiceApiDatasource(ref.watch(apiClientProvider)),
);

final _serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepositoryImpl(ref.watch(_serviceDatasourceProvider)),
);

final getServicesUseCaseProvider = Provider<GetServicesUseCase>(
  (ref) => GetServicesUseCase(ref.watch(_serviceRepositoryProvider)),
);
