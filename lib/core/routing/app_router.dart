import 'package:civic_app/features/account/presentation/pages/account_page.dart';
import 'package:civic_app/features/appointments/presentation/pages/appointment_page.dart';
import 'package:civic_app/features/articles/presentation/pages/article_detail_page.dart';
import 'package:civic_app/features/articles/presentation/pages/articles_page.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:civic_app/features/home/presentation/pages/home_page.dart';
import 'package:civic_app/features/polls/presentation/pages/polls_page.dart';
import 'package:civic_app/features/services/presentation/pages/services_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen<AsyncValue<bool>>(
    authStateProvider,
    (previous, next) => notifier.notify(),
  );
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authValue = ref.read(authStateProvider);
      final isAuthenticated = authValue.valueOrNull == true;
      final isOnAuth = state.matchedLocation == '/auth';
      // Actualités, services et sondages sont un contenu public côté
      // civic_api (cahier des charges : un citoyen non connecté peut les
      // consulter, seul le vote/la prise de rendez-vous exige un compte)
      // — pas de redirection vers /auth pour ces routes.
      final isPublicRoute =
          isOnAuth ||
          state.matchedLocation == '/home' ||
          state.matchedLocation.startsWith('/articles') ||
          state.matchedLocation == '/services' ||
          state.matchedLocation == '/polls';
      if (!isAuthenticated && !isPublicRoute) return '/auth';
      if (isAuthenticated && isOnAuth) return '/home';
      return null;
    },
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
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
    ],
  );
});
