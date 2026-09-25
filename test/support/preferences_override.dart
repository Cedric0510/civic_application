import 'package:civic_app/features/accessibility/presentation/controllers/display_settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Override> preferencesOverride([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return sharedPreferencesProvider.overrideWithValue(
    await SharedPreferences.getInstance(),
  );
}
