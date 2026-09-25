import 'package:civic_app/core/theme/app_theme.dart';
import 'package:civic_app/features/accessibility/presentation/comfort_text_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'preferences_override.dart';

Future<void> pumpPage(
  WidgetTester tester, {
  required Widget page,
  bool comfort = false,
  double systemScale = 1.0,
  List<Override> overrides = const [],
  Size size = const Size(360, 740),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = systemScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => page),
      GoRoute(path: '/auth', builder: (_, _) => const SizedBox()),
      GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const SizedBox()),
      GoRoute(path: '/feedback', builder: (_, _) => const SizedBox()),
      GoRoute(path: '/legal/:kind', builder: (_, _) => const SizedBox()),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [await preferencesOverride(), ...overrides],
      child: MaterialApp.router(
        theme: comfort ? AppTheme.comfort : AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) =>
            ComfortTextScale(comfort: comfort, child: child!),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
