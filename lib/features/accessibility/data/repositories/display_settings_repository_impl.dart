import 'package:civic_app/features/accessibility/data/datasources/display_settings_local_datasource.dart';
import 'package:civic_app/features/accessibility/domain/entities/display_settings.dart';
import 'package:civic_app/features/accessibility/domain/repositories/display_settings_repository.dart';

class DisplaySettingsRepositoryImpl implements DisplaySettingsRepository {
  const DisplaySettingsRepositoryImpl(this._datasource);

  final DisplaySettingsLocalDatasource _datasource;

  @override
  DisplaySettings load() =>
      DisplaySettings(comfortMode: _datasource.readComfortMode());

  @override
  Future<void> save(DisplaySettings settings) =>
      _datasource.writeComfortMode(settings.comfortMode);
}
