import 'package:civic_app/features/settings/data/models/city_settings_model.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({Object? disabledModules}) => {
  'name': 'Bessan',
  'disabledModules': ?disabledModules,
};

void main() {
  group('CitySettingsModel.fromJson disabledModules', () {
    test('reads the disabled modules sent by the API', () {
      final settings = CitySettingsModel.fromJson(
        _json(disabledModules: ['POLLS', 'WEATHER']),
      );

      expect(settings.disabledModules, {AppModule.polls, AppModule.weather});
      expect(settings.isEnabled(AppModule.polls), isFalse);
      expect(settings.isEnabled(AppModule.articles), isTrue);
    });

    test('an empty list means every module is on', () {
      final settings = CitySettingsModel.fromJson(_json(disabledModules: []));

      expect(settings.disabledModules, isEmpty);
      for (final module in AppModule.values) {
        expect(settings.isEnabled(module), isTrue);
      }
    });

    test('ignores a module this version of the app does not know yet', () {
      final settings = CitySettingsModel.fromJson(
        _json(disabledModules: ['POLLS', 'HOLOGRAMS']),
      );

      expect(settings.disabledModules, {AppModule.polls});
    });

    test('an older API without the field leaves every module on', () {
      final settings = CitySettingsModel.fromJson(_json());

      expect(settings.disabledModules, isEmpty);
    });
  });

  group('AppModule.fromApiName', () {
    test('round-trips every module', () {
      for (final module in AppModule.values) {
        expect(AppModule.fromApiName(module.apiName), module);
      }
    });

    test('returns null for an unknown name', () {
      expect(AppModule.fromApiName('NOPE'), isNull);
    });
  });
}
