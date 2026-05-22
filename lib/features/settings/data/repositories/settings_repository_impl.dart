import 'package:civic_app/features/settings/data/datasources/settings_supabase_datasource.dart';
import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._datasource);

  final SettingsSupabaseDatasource _datasource;

  @override
  Future<CitySettings> getCitySettings() => _datasource.getCitySettings();
}
