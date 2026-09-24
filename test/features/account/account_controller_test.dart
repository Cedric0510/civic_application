import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/account/presentation/controllers/account_controller.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _bessan = CitizenSession(
  commune: CommuneRef(id: 'c1', name: 'Bessan', slug: 'bessan'),
  role: CitizenRole.user,
);
const _saintMartin = CitizenSession(
  commune: CommuneRef(
    id: 'c2',
    name: 'Saint-Martin-de-Belleville',
    slug: 'saint-martin-de-belleville',
  ),
  role: CitizenRole.user,
);

class _FakeAuthRepository extends Fake implements AuthRepository {
  Object? changeCommuneError;
  String? lastSlug;

  @override
  Future<CitizenSession> changeCommune(String communeSlug) async {
    lastSlug = communeSlug;
    if (changeCommuneError != null) throw changeCommuneError!;
    return _saintMartin;
  }
}

class _FakeAccountRepository extends Fake implements AccountRepository {}

// fetchSession() is overridden, so the ApiClient/TokenStorage given to
// super() are never exercised -- placeholders only.
class _FakeAuthDatasource extends AuthApiDatasource {
  _FakeAuthDatasource()
    : super(
        ApiClient(
          MockClient((_) async => http.Response('{}', 200)),
          TokenStorage(),
        ),
        TokenStorage(),
      );

  @override
  Future<CitizenSession?> fetchSession() async => _bessan;
}

void main() {
  late _FakeAuthRepository fakeRepo;
  late ProviderContainer container;
  late List<AsyncValue<CitizenSession?>> sessionHistory;

  setUp(() async {
    fakeRepo = _FakeAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
        authDatasourceProvider.overrideWithValue(_FakeAuthDatasource()),
        accountRepositoryProvider.overrideWithValue(_FakeAccountRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(accountControllerProvider, (_, _) {});
    await container.read(authStateProvider.notifier).refresh();

    sessionHistory = [];
    container.listen(authStateProvider, (_, next) => sessionHistory.add(next));
  });

  test(
    'changeCommune moves the session to the new commune without ever passing through a loading state',
    () async {
      await container
          .read(accountControllerProvider.notifier)
          .changeCommune('saint-martin-de-belleville');

      expect(fakeRepo.lastSlug, 'saint-martin-de-belleville');
      expect(container.read(authStateProvider).value, _saintMartin);
      expect(sessionHistory, isNotEmpty);
      expect(sessionHistory.any((state) => state.isLoading), isFalse);
      expect(container.read(accountControllerProvider).hasError, isFalse);
    },
  );

  test(
    'a rejected change surfaces the error and keeps the current session',
    () async {
      fakeRepo.changeCommuneError = const NotFoundException(
        'Commune introuvable.',
      );

      await container
          .read(accountControllerProvider.notifier)
          .changeCommune('nulle-part');

      expect(container.read(accountControllerProvider).hasError, isTrue);
      expect(container.read(authStateProvider).value, _bessan);
    },
  );
}
