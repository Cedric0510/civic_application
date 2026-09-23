import 'package:civic_app/core/providers/http_client_provider.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/features/weather/data/datasources/weather_api_datasource.dart';
import 'package:civic_app/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:civic_app/features/weather/domain/usecases/get_weather_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weatherDatasourceProvider = Provider<WeatherApiDatasource>((ref) {
  return WeatherApiDatasource(ref.watch(httpClientProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(ref.watch(weatherDatasourceProvider));
});

final getWeatherUseCaseProvider = Provider<GetWeatherUseCase>((ref) {
  return GetWeatherUseCase(ref.watch(weatherRepositoryProvider));
});

// Attend explicitement citySettingsProvider (commune du citoyen connecté,
// résolue dynamiquement) plutôt que de retomber sur un nom de ville en dur :
// dans une appli multi-commune, un mauvais repli afficherait la météo d'une
// autre ville que la sienne.
final weatherProvider = FutureProvider<Weather>((ref) async {
  final settings = await ref.watch(citySettingsProvider.future);
  return ref.read(getWeatherUseCaseProvider)(settings.villageName);
});
