import 'package:civic_app/core/lifecycle/app_resume_observer.dart';
import 'package:civic_app/core/routing/app_router.dart';
import 'package:civic_app/core/theme/app_theme.dart';
import 'package:civic_app/features/accessibility/presentation/comfort_text_scale.dart';
import 'package:civic_app/features/accessibility/presentation/controllers/display_settings_controller.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const CivicApp(),
    ),
  );
}

class CivicApp extends ConsumerWidget {
  const CivicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final comfort = ref.watch(displaySettingsProvider).comfortMode;
    return AppResumeObserver(
      onResume: () => ref.invalidate(citySettingsProvider),
      child: MaterialApp.router(
        title: 'City-Co',
        theme: comfort ? AppTheme.comfort : AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) =>
            ComfortTextScale(comfort: comfort, child: child!),
        routerConfig: router,
      ),
    );
  }
}
