import 'package:civic_app/features/services/data/datasources/service_supabase_datasource.dart';
import 'package:civic_app/features/services/data/repositories/service_repository_impl.dart';
import 'package:civic_app/features/services/domain/repositories/service_repository.dart';
import 'package:civic_app/features/services/domain/usecases/get_services_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final _serviceDatasourceProvider = Provider<ServiceSupabaseDatasource>(
  (ref) => ServiceSupabaseDatasource(ref.read(_supabaseClientProvider)),
);

final _serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepositoryImpl(ref.read(_serviceDatasourceProvider)),
);

final getServicesUseCaseProvider = Provider<GetServicesUseCase>(
  (ref) => GetServicesUseCase(ref.read(_serviceRepositoryProvider)),
);
