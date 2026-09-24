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

final weatherClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 15), (_) => DateTime.now());
});

// La météo affichée suit l'heure : le serveur ne la rafraîchit que deux fois
// par jour, on choisit donc dans son prévisionnel le créneau le plus proche.
final currentWeatherProvider = Provider.autoDispose<AsyncValue<Weather?>>((
  ref,
) {
  final now = ref.watch(weatherClockProvider).valueOrNull ?? DateTime.now();
  return ref.watch(weatherProvider).whenData((weather) => weather?.atTime(now));
});
