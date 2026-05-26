import 'package:civic_app/features/weather/domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.temperature,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List<dynamic>;
    final mainMap = json['main'] as Map<String, dynamic>;
    final windMap = json['wind'] as Map<String, dynamic>;
    return WeatherModel(
      cityName: json['name'] as String,
      temperature: (mainMap['temp'] as num).toDouble(),
      description: weatherList.first['description'] as String,
      iconCode: weatherList.first['icon'] as String,
      humidity: mainMap['humidity'] as int,
      windSpeed: (windMap['speed'] as num).toDouble(),
    );
  }
}
