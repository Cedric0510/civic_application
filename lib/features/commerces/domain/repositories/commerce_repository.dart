import 'package:civic_app/features/commerces/domain/entities/commerce.dart';

abstract class CommerceRepository {
  Future<List<Commerce>> getCommerces();
}
