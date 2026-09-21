import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/services/data/models/service_model.dart';

// Services municipaux : contenu public côté civic_api, comme les articles.
class ServiceApiDatasource {
  const ServiceApiDatasource(this._api);

  final ApiClient _api;

  Future<List<ServiceModel>> getServices() async {
    final json =
        await _api.get(
              '/services?communeSlug='
              '${Uri.encodeQueryComponent(AppConstants.communeSlug)}',
            )
            as List<dynamic>;
    final services = json
        .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
        .toList();
    services.sort((a, b) {
      final categoryCompare = (a.category ?? '').compareTo(b.category ?? '');
      return categoryCompare != 0
          ? categoryCompare
          : a.name.compareTo(b.name);
    });
    return services;
  }
}
