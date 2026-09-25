import 'package:civic_app/features/accessibility/domain/entities/display_settings.dart';

abstract class DisplaySettingsRepository {
  DisplaySettings load();
  Future<void> save(DisplaySettings settings);
}
