import 'package:civic_app/features/legal/data/datasources/legal_api_datasource.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/features/legal/domain/repositories/legal_repository.dart';

class LegalRepositoryImpl implements LegalRepository {
  const LegalRepositoryImpl(this._datasource);

  final LegalApiDatasource _datasource;

  @override
  Future<LegalTexts> getLegalTexts(String communeSlug) =>
      _datasource.getLegalTexts(communeSlug);
}
