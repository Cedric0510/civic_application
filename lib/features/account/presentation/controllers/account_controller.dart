import 'package:civic_app/features/account/domain/usecases/delete_account_usecase.dart';
import 'package:civic_app/features/account/domain/usecases/request_data_export_usecase.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountController extends StateNotifier<AsyncValue<void>> {
  AccountController(this._ref, this._deleteAccount, this._requestDataExport)
    : super(const AsyncData(null));

  final Ref _ref;
  final DeleteAccountUseCase _deleteAccount;
  final RequestDataExportUseCase _requestDataExport;

  Future<bool> requestDataExport() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _requestDataExport());
    return !state.hasError;
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _deleteAccount();
      // Le compte n'existe plus : la session locale doit être effacée elle
      // aussi (réutilise le SignOutUseCase de la feature auth, seule source
      // de vérité pour "effacer le token").
      await _ref.read(signOutUseCaseProvider)();
      await _ref.read(authStateProvider.notifier).refresh();
    });
  }

  Future<void> changeCommune(String communeSlug) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _ref.read(changeCommuneUseCaseProvider)(
        communeSlug,
      );
      _ref.read(authStateProvider.notifier).updateSession(session);
    });
  }
}

final accountControllerProvider =
    StateNotifierProvider.autoDispose<AccountController, AsyncValue<void>>((
      ref,
    ) {
      return AccountController(
        ref,
        ref.watch(deleteAccountUseCaseProvider),
        ref.watch(requestDataExportUseCaseProvider),
      );
    });
