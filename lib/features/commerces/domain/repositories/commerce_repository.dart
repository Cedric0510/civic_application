import 'package:cross_file/cross_file.dart';

import 'package:civic_app/features/commerces/domain/entities/commerce.dart';

abstract class CommerceRepository {
  Future<List<Commerce>> getCommerces();
  Future<Commerce> getCommerceById(String id);
  Future<void> updateCommerce(Commerce commerce);
  Future<String> uploadPhoto(XFile file);
}
