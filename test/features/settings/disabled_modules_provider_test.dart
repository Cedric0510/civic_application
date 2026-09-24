import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _session = CitizenSession(
  commune: CommuneRef(id: 'c1', name: 'Bessan', slug: 'bessan'),
  role: CitizenRole.user,
);

class _FakeAuthDatasource extends AuthApiDatasource {
  _FakeAuthDatasource(this._session)
    : super(
        ApiClient(
          MockClient((_) async => http.Response('{}', 200)),
          TokenStorage(),
        ),
        TokenStorage(),
      );

  final CitizenSession? _session;

  @override
  Future<CitizenSession?> fetchSession() async => _session;
}

Future<ProviderContainer> _container({
  required CitizenSession? session,
  required Future<CitySettings> Function() settings,
}) async {
  final container = ProviderContainer(
    overrides: [
      authDatasourceProvider.overrideWithValue(_FakeAuthDatasource(session)),
      citySettingsProvider.overrideWith((ref) => settings()),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authStateProvider.notifier).refresh();
  return container;
}

void main() {
  test('exposes the modules the commune has switched off', () async {
    final container = await _container(
      session: _session,
      settings: () async => const CitySettings(
        villageName: 'Bessan',
        disabledModules: {AppModule.polls, AppModule.weather},
      ),
    );
    await container.read(citySettingsProvider.future);

    expect(container.read(disabledModulesProvider), {
      AppModule.polls,
      AppModule.weather,
    });
    expect(container.read(moduleEnabledProvider(AppModule.polls)), isFalse);
    expect(container.read(moduleEnabledProvider(AppModule.articles)), isTrue);
  });

  test('keeps every module on while the settings are loading', () async {
    final container = await _container(
      session: _session,
      settings: () => Future.delayed(
        const Duration(days: 1),
        () => const CitySettings(villageName: 'Bessan'),
      ),
    );

    expect(container.read(disabledModulesProvider), isEmpty);
    expect(container.read(moduleEnabledProvider(AppModule.polls)), isTrue);
  });

  test('keeps every module on when the settings cannot be fetched', () async {
    final container = await _container(
      session: _session,
      settings: () async => throw Exception('hors ligne'),
    );
    await container
        .read(citySettingsProvider.future)
        .catchError((_) => const CitySettings(villageName: ''));

    expect(container.read(disabledModulesProvider), isEmpty);
  });

  test('ignores the commune settings when nobody is signed in', () async {
    final container = await _container(
      session: null,
      settings: () async => const CitySettings(
        villageName: 'Bessan',
        disabledModules: {AppModule.polls},
      ),
    );

    expect(container.read(disabledModulesProvider), isEmpty);
  });
}
