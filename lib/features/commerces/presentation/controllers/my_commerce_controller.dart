import 'package:cross_file/cross_file.dart';

import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/domain/usecases/update_commerce_usecase.dart';
import 'package:civic_app/features/commerces/domain/usecases/upload_commerce_photo_usecase.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerces_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fiche du commerce géré par le citoyen connecté (role = COMMERCANT) --
// distinct de commercesControllerProvider, qui liste tous les commerces
// publiquement. Autodispose : rechargé à chaque ouverture de la page.
final myCommerceProvider = FutureProvider.autoDispose<Commerce>((ref) async {
  final session = ref.watch(authStateProvider).valueOrNull;
  final commerceId = session?.managedCommerce?.id;
  if (commerceId == null) {
    throw StateError('Ce compte ne gère aucun commerce.');
  }
  return ref.read(getCommerceByIdUseCaseProvider)(commerceId);
});

class MyCommerceController extends StateNotifier<AsyncValue<void>> {
  MyCommerceController(this._ref, this._updateUseCase, this._uploadUseCase)
    : super(const AsyncData(null));

  final Ref _ref;
  final UpdateCommerceUseCase _updateUseCase;
  final UploadCommercePhotoUseCase _uploadUseCase;

  Future<void> save(Commerce commerce, {XFile? photo}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final imageUrl = photo != null
          ? await _uploadUseCase(photo)
          : commerce.imageUrl;
      await _updateUseCase(
        Commerce(
          id: commerce.id,
          name: commerce.name,
          category: commerce.category,
          description: commerce.description,
          email: commerce.email,
          phone: commerce.phone,
          address: commerce.address,
          hours: commerce.hours,
          imageUrl: imageUrl,
          notes: commerce.notes,
        ),
      );
      _ref.invalidate(myCommerceProvider);
    });
  }
}

final myCommerceControllerProvider =
    StateNotifierProvider.autoDispose<MyCommerceController, AsyncValue<void>>(
      (ref) => MyCommerceController(
        ref,
        ref.read(updateCommerceUseCaseProvider),
        ref.read(uploadCommercePhotoUseCaseProvider),
      ),
    );
