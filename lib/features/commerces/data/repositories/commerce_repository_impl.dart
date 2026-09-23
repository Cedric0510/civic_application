import 'dart:io';

import 'package:civic_app/features/commerces/data/datasources/commerce_api_datasource.dart';
import 'package:civic_app/features/commerces/data/models/commerce_model.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';

class CommerceRepositoryImpl implements CommerceRepository {
  const CommerceRepositoryImpl(this._datasource);

  final CommerceApiDatasource _datasource;

  @override
  Future<List<Commerce>> getCommerces() => _datasource.getCommerces();

  @override
  Future<Commerce> getCommerceById(String id) =>
      _datasource.getCommerceById(id);

  @override
  Future<void> updateCommerce(Commerce commerce) {
    return _datasource.updateCommerce(
      commerce.id,
      CommerceModel(
        id: commerce.id,
        name: commerce.name,
        category: commerce.category,
        description: commerce.description,
        email: commerce.email,
        phone: commerce.phone,
        address: commerce.address,
        hours: commerce.hours,
        imageUrl: commerce.imageUrl,
        notes: commerce.notes,
      ),
    );
  }

  @override
  Future<String> uploadPhoto(File file) => _datasource.uploadPhoto(file);
}
