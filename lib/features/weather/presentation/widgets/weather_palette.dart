import 'package:civic_app/features/weather/domain/entities/weather_condition.dart';
import 'package:flutter/material.dart';

abstract final class WeatherPalette {
  static List<Color> skyFor(String iconCode) {
    final condition = WeatherCondition.fromIconCode(iconCode);
    final sky = isNightIconCode(iconCode) ? _night : _day;
    return sky[condition]!;
  }

  static const _day = <WeatherCondition, List<Color>>{
    WeatherCondition.clear: [Color(0xFF15529E), Color(0xFF2F7ACB)],
    WeatherCondition.partlyCloudy: [Color(0xFF35648F), Color(0xFF5A83A8)],
    WeatherCondition.cloudy: [Color(0xFF4A5A6A), Color(0xFF6F8091)],
    WeatherCondition.rain: [Color(0xFF2F3E52), Color(0xFF4E6580)],
    WeatherCondition.storm: [Color(0xFF262B3E), Color(0xFF44506B)],
    WeatherCondition.snow: [Color(0xFF48627D), Color(0xFF667F99)],
    WeatherCondition.mist: [Color(0xFF56636E), Color(0xFF77858F)],
  };

  static const _night = <WeatherCondition, List<Color>>{
    WeatherCondition.clear: [Color(0xFF0B1330), Color(0xFF1E3266)],
    WeatherCondition.partlyCloudy: [Color(0xFF111A38), Color(0xFF2C3D69)],
    WeatherCondition.cloudy: [Color(0xFF1A2236), Color(0xFF34425E)],
    WeatherCondition.rain: [Color(0xFF1B2433), Color(0xFF36485E)],
    WeatherCondition.storm: [Color(0xFF1A1E2E), Color(0xFF343C54)],
    WeatherCondition.snow: [Color(0xFF243247), Color(0xFF45607C)],
    WeatherCondition.mist: [Color(0xFF232B33), Color(0xFF444F59)],
  };
}
