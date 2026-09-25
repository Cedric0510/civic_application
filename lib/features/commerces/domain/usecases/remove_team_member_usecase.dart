import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';

class RemoveTeamMemberUseCase {
  const RemoveTeamMemberUseCase(this._repository);

  final CommerceTeamRepository _repository;

  Future<void> call(String commerceId, String memberId) =>
      _repository.removeMember(commerceId, memberId);
}
