import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/legal/data/datasources/legal_api_datasource.dart';
import 'package:civic_app/features/legal/data/repositories/legal_repository_impl.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/features/legal/domain/repositories/legal_repository.dart';
import 'package:civic_app/features/legal/domain/usecases/get_legal_texts_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final legalDatasourceProvider = Provider<LegalApiDatasource>((ref) {
  return LegalApiDatasource(ref.watch(apiClientProvider));
});

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LegalRepositoryImpl(ref.watch(legalDatasourceProvider));
});

final getLegalTextsUseCaseProvider = Provider<GetLegalTextsUseCase>((ref) {
  return GetLegalTextsUseCase(ref.watch(legalRepositoryProvider));
});

final legalTextsProvider = FutureProvider.autoDispose
    .family<LegalTexts, String>((ref, communeSlug) {
      return ref.watch(getLegalTextsUseCaseProvider)(communeSlug);
    });
