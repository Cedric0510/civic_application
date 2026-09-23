import 'dart:io';

import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';

class UploadCommercePhotoUseCase {
  const UploadCommercePhotoUseCase(this._repository);

  final CommerceRepository _repository;

  Future<String> call(File file) => _repository.uploadPhoto(file);
}
