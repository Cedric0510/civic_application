import 'package:civic_app/features/settings/domain/entities/app_module.dart';

const Map<String, AppModule> _moduleByRootSegment = {
  'articles': AppModule.articles,
  'polls': AppModule.polls,
  'services': AppModule.services,
  'appointments': AppModule.appointments,
  'commerces': AppModule.commerces,
  'my-commerce': AppModule.commerces,
  'reports': AppModule.reports,
  'weather': AppModule.weather,
};

AppModule? moduleForLocation(String location) {
  final segments = Uri.parse(location).pathSegments;
  return segments.isEmpty ? null : _moduleByRootSegment[segments.first];
}

const Set<String> _guestOnlyLocations = {'/auth', '/forgot-password'};
const String _openLocationPrefix = '/legal/';

String? resolveRedirect({
  required bool isAuthenticated,
  required String location,
  required Set<AppModule> disabledModules,
}) {
  final isGuestOnly = _guestOnlyLocations.contains(location);
  final isOpen = location.startsWith(_openLocationPrefix);
  // Toute l'app exige un compte : seules les pages d'accès et les textes
  // légaux (à lire avant l'inscription) sont ouverts à un visiteur.
  if (!isAuthenticated && !isGuestOnly && !isOpen) return '/auth';
  if (isAuthenticated && isGuestOnly) return '/home';
  final module = moduleForLocation(location);
  if (module != null && disabledModules.contains(module)) return '/home';
  return null;
}
