import 'package:civic_app/features/settings/domain/entities/city_settings.dart';

class CitySettingsModel extends CitySettings {
  const CitySettingsModel({required super.villageName});

  // Reflète GET /communes/:slug (civic_api) — 'name', pas 'village_name'.
  factory CitySettingsModel.fromJson(Map<String, dynamic> json) {
    return CitySettingsModel(villageName: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': villageName};
  }
}
