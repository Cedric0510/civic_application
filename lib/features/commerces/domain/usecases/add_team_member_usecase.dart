import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';

class AddTeamMemberUseCase {
  const AddTeamMemberUseCase(this._repository);

  final CommerceTeamRepository _repository;

  Future<TeamAddOutcome> call(String commerceId, String email) =>
      _repository.addMember(commerceId, email.trim().toLowerCase());
}
