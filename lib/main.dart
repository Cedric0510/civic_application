import 'package:civic_app/core/routing/app_router.dart';
import 'package:civic_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim();
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();
  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
  );
  runApp(const ProviderScope(child: CivicApp()));
}

class CivicApp extends ConsumerWidget {
  const CivicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'City-Co',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
