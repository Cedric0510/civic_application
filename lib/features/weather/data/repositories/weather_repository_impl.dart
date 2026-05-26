import 'package:civic_app/features/weather/data/datasources/weather_api_datasource.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl(this._datasource);

  final WeatherApiDatasource _datasource;

  @override
  Future<Weather> getWeather(String cityName) =>
      _datasource.getWeather(cityName);
}
