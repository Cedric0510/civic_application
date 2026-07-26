import 'dart:convert';

import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/services/data/models/service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Services municipaux : contenu public côté civic_api, comme les articles.
class ServiceApiDatasource {
  const ServiceApiDatasource(this._client);

  final http.Client _client;

  String get _baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:4000');

  Future<List<ServiceModel>> getServices() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/services'
        '?communeSlug=${Uri.encodeQueryComponent(AppConstants.communeSlug)}',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw const DatabaseException();
      }
      final json = jsonDecode(response.body) as List<dynamic>;
      final services = json
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList();
      services.sort((a, b) {
        final categoryCompare = (a.category ?? '').compareTo(
          b.category ?? '',
        );
        return categoryCompare != 0
            ? categoryCompare
            : a.name.compareTo(b.name);
      });
      return services;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
