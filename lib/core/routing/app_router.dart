import 'package:civic_app/core/routing/app_redirect.dart';
import 'package:civic_app/features/account/presentation/pages/account_page.dart';
import 'package:civic_app/features/appointments/presentation/pages/appointment_page.dart';
import 'package:civic_app/features/articles/presentation/pages/article_detail_page.dart';
import 'package:civic_app/features/articles/presentation/pages/articles_page.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:civic_app/features/commerces/presentation/pages/commerces_page.dart';
import 'package:civic_app/features/commerces/presentation/pages/my_commerce_page.dart';
import 'package:civic_app/features/home/presentation/pages/home_page.dart';
import 'package:civic_app/features/polls/presentation/pages/polls_page.dart';
import 'package:civic_app/features/reports/presentation/pages/reports_page.dart';
import 'package:civic_app/features/services/presentation/pages/services_page.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/features/weather/presentation/pages/weather_detail_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen<AsyncValue<CitizenSession?>>(
    authStateProvider,
    (previous, next) => notifier.notify(),
  );
  ref.listen<Set<AppModule>>(
    disabledModulesProvider,
    (previous, next) => notifier.notify(),
  );
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) => resolveRedirect(
      isAuthenticated: ref.read(authStateProvider).valueOrNull != null,
      location: state.matchedLocation,
      disabledModules: ref.read(disabledModulesProvider),
    ),
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/articles',
        builder: (context, state) => const ArticlesPage(),
      ),
      GoRoute(
        path: '/articles/:id',
        builder: (context, state) =>
            ArticleDetailPage(articleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentPage(),
      ),
      GoRoute(path: '/polls', builder: (context, state) => const PollsPage()),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesPage(),
      ),
      GoRoute(
        path: '/commerces',
        builder: (context, state) => const CommercesPage(),
      ),
      GoRoute(
        path: '/my-commerce',
        builder: (context, state) => const MyCommercePage(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherDetailPage(),
      ),
    ],
  );
});
