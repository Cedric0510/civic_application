import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/commerces/data/datasources/commerce_api_datasource.dart';
import 'package:civic_app/features/commerces/data/repositories/commerce_repository_impl.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';
import 'package:civic_app/features/commerces/domain/usecases/get_commerces_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _commerceDatasourceProvider = Provider<CommerceApiDatasource>(
  (ref) => CommerceApiDatasource(ref.watch(apiClientProvider)),
);

final _commerceRepositoryProvider = Provider<CommerceRepository>(
  (ref) => CommerceRepositoryImpl(ref.watch(_commerceDatasourceProvider)),
);

final getCommercesUseCaseProvider = Provider<GetCommercesUseCase>(
  (ref) => GetCommercesUseCase(ref.watch(_commerceRepositoryProvider)),
);
