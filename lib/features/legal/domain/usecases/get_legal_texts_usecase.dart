import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/features/legal/domain/repositories/legal_repository.dart';

class GetLegalTextsUseCase {
  const GetLegalTextsUseCase(this._repository);

  final LegalRepository _repository;

  Future<LegalTexts> call(String communeSlug) =>
      _repository.getLegalTexts(communeSlug);
}
