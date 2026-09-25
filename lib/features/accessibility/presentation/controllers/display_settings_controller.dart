import 'package:civic_app/features/accessibility/data/datasources/display_settings_local_datasource.dart';
import 'package:civic_app/features/accessibility/data/repositories/display_settings_repository_impl.dart';
import 'package:civic_app/features/accessibility/domain/entities/display_settings.dart';
import 'package:civic_app/features/accessibility/domain/repositories/display_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider doit être remplacé au démarrage de l\'application.',
  );
});

final displaySettingsRepositoryProvider = Provider<DisplaySettingsRepository>((
  ref,
) {
  return DisplaySettingsRepositoryImpl(
    DisplaySettingsLocalDatasource(ref.watch(sharedPreferencesProvider)),
  );
});

class DisplaySettingsController extends StateNotifier<DisplaySettings> {
  DisplaySettingsController(this._repository) : super(_repository.load());

  final DisplaySettingsRepository _repository;

  Future<void> setComfortMode(bool enabled) async {
    state = state.copyWith(comfortMode: enabled);
    await _repository.save(state);
  }

  Future<void> toggleComfortMode() => setComfortMode(!state.comfortMode);
}

final displaySettingsProvider =
    StateNotifierProvider<DisplaySettingsController, DisplaySettings>((ref) {
      return DisplaySettingsController(
        ref.watch(displaySettingsRepositoryProvider),
      );
    });
