import 'package:civic_app/features/account/domain/usecases/delete_account_usecase.dart';
import 'package:civic_app/features/account/domain/usecases/update_city_usecase.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountController extends StateNotifier<AsyncValue<void>> {
  AccountController(this._updateCity, this._deleteAccount)
    : super(const AsyncData(null));

  final UpdateCityUseCase _updateCity;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> updateCity(String city) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _updateCity(city));
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _deleteAccount());
  }
}

final accountControllerProvider =
    StateNotifierProvider.autoDispose<AccountController, AsyncValue<void>>((
      ref,
    ) {
      return AccountController(
        ref.watch(updateCityUseCaseProvider),
        ref.watch(deleteAccountUseCaseProvider),
      );
    });
