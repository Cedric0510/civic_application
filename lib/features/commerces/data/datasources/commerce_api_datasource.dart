import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/commerces/data/models/commerce_model.dart';

// Commerçants : contenu public côté civic_api, comme les services.
class CommerceApiDatasource {
  const CommerceApiDatasource(this._api);

  final ApiClient _api;

  Future<List<CommerceModel>> getCommerces() async {
    final json =
        await _api.get(
              '/commerces?communeSlug='
              '${Uri.encodeQueryComponent(AppConstants.communeSlug)}',
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
}
