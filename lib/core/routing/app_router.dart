import 'package:civic_app/features/appointments/presentation/pages/appointment_page.dart';
import 'package:civic_app/features/articles/presentation/pages/article_detail_page.dart';
import 'package:civic_app/features/articles/presentation/pages/articles_page.dart';
import 'package:civic_app/features/home/presentation/pages/home_page.dart';
import 'package:civic_app/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/articles',
            builder: (context, state) => const ArticlesPage(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentPage(),
          ),
          GoRoute(
            path: '/polls',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Polls'))),
          ),
        ],
      ),
      GoRoute(
        path: '/articles/:id',
        builder: (context, state) =>
            ArticleDetailPage(articleId: state.pathParameters['id']!),
      ),
    ],
  );
});
