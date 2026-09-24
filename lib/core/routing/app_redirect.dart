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

String? resolveRedirect({
  required bool isAuthenticated,
  required String location,
  required Set<AppModule> disabledModules,
}) {
  final isOnAuth = location == '/auth';
  // Toute l'app exige un compte : /auth est la seule route publique.
  if (!isAuthenticated && !isOnAuth) return '/auth';
  if (isAuthenticated && isOnAuth) return '/home';
  final module = moduleForLocation(location);
  if (module != null && disabledModules.contains(module)) return '/home';
  return null;
}
