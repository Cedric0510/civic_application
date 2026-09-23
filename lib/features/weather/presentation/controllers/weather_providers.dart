import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dérivé de citySettingsProvider (GET /communes/:slug, qui embarque la météo
// mise en cache côté serveur) -- aucun appel réseau propre à cette feature,
// jamais d'appel direct à une API météo tierce depuis l'appli.
final weatherProvider = FutureProvider<Weather?>((ref) async {
  final settings = await ref.watch(citySettingsProvider.future);
  return settings.weather;
});
