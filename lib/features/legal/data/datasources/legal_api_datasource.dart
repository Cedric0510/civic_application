import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';

class LegalApiDatasource {
  const LegalApiDatasource(this._api);

  final ApiClient _api;

  Future<LegalTexts> getLegalTexts(String communeSlug) async {
    final json =
        await _api.get('/communes/${Uri.encodeComponent(communeSlug)}/legal')
            as Map<String, dynamic>;
    return LegalTexts(
      communeName: json['communeName'] as String,
      legalNotice: json['legalNotice'] as String,
      privacyPolicy: json['privacyPolicy'] as String,
    );
  }
}
