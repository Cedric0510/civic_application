import 'package:civic_app/features/settings/domain/entities/city_settings.dart';

class CitySettingsModel extends CitySettings {
  const CitySettingsModel({required super.villageName});

  factory CitySettingsModel.fromJson(Map<String, dynamic> json) {
    return CitySettingsModel(villageName: json['village_name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'village_name': villageName};
  }
}
