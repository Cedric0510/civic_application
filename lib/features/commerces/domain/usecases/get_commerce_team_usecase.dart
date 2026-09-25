import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';

class GetCommerceTeamUseCase {
  const GetCommerceTeamUseCase(this._repository);

  final CommerceTeamRepository _repository;

  Future<CommerceTeam> call(String commerceId) =>
      _repository.getTeam(commerceId);
}
