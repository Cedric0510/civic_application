import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/repositories/weather_repository.dart';

class GetWeatherUseCase {
  const GetWeatherUseCase(this._repository);

  final WeatherRepository _repository;

  Future<Weather> call(String cityName) => _repository.getWeather(cityName);
}
