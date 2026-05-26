import 'dart:convert';

import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/weather/data/models/weather_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherApiDatasource {
  const WeatherApiDatasource(this._client);

  final http.Client _client;

  Future<WeatherModel> getWeather(String cityName) async {
    final apiKey = dotenv.get('OPENWEATHERMAP_API_KEY', fallback: '');
    if (apiKey.isEmpty) {
      throw const NetworkException();
    }
    try {
      final uri = Uri.parse(
        '${AppConstants.openWeatherMapBaseUrl}/weather'
        '?q=${Uri.encodeComponent(cityName)}'
        '&appid=$apiKey'
        '&units=metric'
        '&lang=fr',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw const NetworkException();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(json);
    } on NetworkException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
