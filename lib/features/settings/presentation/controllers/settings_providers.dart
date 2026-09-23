import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/settings/data/datasources/settings_api_datasource.dart';
import 'package:civic_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:civic_app/features/settings/domain/usecases/get_city_settings_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsDatasourceProvider = Provider<SettingsApiDatasource>((ref) {
  return SettingsApiDatasource(
    ref.watch(apiClientProvider),
    ref.watch(authStateProvider).valueOrNull!.slug,
  );
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
