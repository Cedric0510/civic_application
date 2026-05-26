import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/features/weather/data/datasources/weather_api_datasource.dart';
import 'package:civic_app/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:civic_app/features/weather/domain/usecases/get_weather_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final weatherDatasourceProvider = Provider<WeatherApiDatasource>((ref) {
  return WeatherApiDatasource(ref.watch(httpClientProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(ref.watch(weatherDatasourceProvider));
});

final getWeatherUseCaseProvider = Provider<GetWeatherUseCase>((ref) {
  return GetWeatherUseCase(ref.watch(weatherRepositoryProvider));
});

final weatherProvider = FutureProvider<Weather>((ref) {
  final settingsAsync = ref.watch(citySettingsProvider);
  final cityName =
      settingsAsync.whenOrNull(data: (s) => s.villageName) ??
      AppConstants.villageName;
  return ref.read(getWeatherUseCaseProvider)(cityName);
});
