import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';

abstract class LegalRepository {
  Future<LegalTexts> getLegalTexts(String communeSlug);
}
