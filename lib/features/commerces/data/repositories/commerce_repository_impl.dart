import 'package:civic_app/features/commerces/data/datasources/commerce_api_datasource.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_repository.dart';

class CommerceRepositoryImpl implements CommerceRepository {
  const CommerceRepositoryImpl(this._datasource);

  final CommerceApiDatasource _datasource;

  @override
  Future<List<Commerce>> getCommerces() => _datasource.getCommerces();
}
