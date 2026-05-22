import 'package:civic_app/core/providers/supabase_provider.dart';
import 'package:civic_app/features/settings/data/datasources/settings_supabase_datasource.dart';
import 'package:civic_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:civic_app/features/settings/domain/usecases/get_city_settings_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsDatasourceProvider = Provider<SettingsSupabaseDatasource>((ref) {
  return SettingsSupabaseDatasource(ref.watch(supabaseClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsDatasourceProvider));
});

final getCitySettingsUseCaseProvider = Provider<GetCitySettingsUseCase>((ref) {
  return GetCitySettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final citySettingsProvider = FutureProvider<CitySettings>((ref) {
  return ref.read(getCitySettingsUseCaseProvider)();
});
