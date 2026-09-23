import 'dart:io';

import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/commerces/data/models/commerce_model.dart';

// Commerçants : contenu public côté civic_api, comme les services.
class CommerceApiDatasource {
  const CommerceApiDatasource(this._api, this._communeSlug);

  final ApiClient _api;
  final String _communeSlug;

  Future<List<CommerceModel>> getCommerces() async {
    final json =
        await _api.get(
              '/commerces?communeSlug='
              '${Uri.encodeQueryComponent(_communeSlug)}',
            )
            as List<dynamic>;
    final commerces = json
        .map((item) => CommerceModel.fromJson(item as Map<String, dynamic>))
        .toList();
    commerces.sort((a, b) {
      final categoryCompare = (a.category ?? '').compareTo(b.category ?? '');
      return categoryCompare != 0
          ? categoryCompare
          : a.name.compareTo(b.name);
    });
    return commerces;
  }

  Future<CommerceModel> getCommerceById(String id) async {
    final json = await _api.get('/commerces/$id') as Map<String, dynamic>;
    return CommerceModel.fromJson(json);
  }

  // Réservé au commerçant assigné à ce commerce -- civic_api revérifie
  // l'appartenance à chaque appel (cf. CommercesService.assertCanEditCommerce),
  // jamais fait confiance au seul JWT.
  Future<void> updateCommerce(String id, CommerceModel commerce) async {
    await _api.patch('/commerces/$id', commerce.toUpdateJson());
  }

  Future<String> uploadPhoto(File file) => _api.uploadImage(file);
}
