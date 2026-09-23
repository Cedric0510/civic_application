import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:equatable/equatable.dart';

class CitySettings extends Equatable {
  const CitySettings({required this.villageName, this.weather});

  final String villageName;

  // Nul tant que civic_api n'a pas encore rafraîchi le cache météo de cette
  // commune (cron quotidien, cf. WeatherService côté serveur).
  final Weather? weather;

  @override
  List<Object?> get props => [villageName, weather];
}
