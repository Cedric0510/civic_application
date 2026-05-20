import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/admin/articles',
    routes: [
      GoRoute(path: '/admin', redirect: (context, state) => '/admin/articles'),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Admin Login'))),
      ),
      GoRoute(
        path: '/admin/articles',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Admin - Articles'))),
      ),
      GoRoute(
        path: '/admin/polls',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Admin - Polls'))),
      ),
      GoRoute(
        path: '/admin/appointments',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Admin - Appointments'))),
      ),
    ],
  );
});
