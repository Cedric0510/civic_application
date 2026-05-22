import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/settings/domain/repositories/settings_repository.dart';

class GetCitySettingsUseCase {
  const GetCitySettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<CitySettings> call() => _repository.getCitySettings();
}
