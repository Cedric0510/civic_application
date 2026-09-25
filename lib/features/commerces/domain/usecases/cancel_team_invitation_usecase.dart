import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';

class CancelTeamInvitationUseCase {
  const CancelTeamInvitationUseCase(this._repository);

  final CommerceTeamRepository _repository;

  Future<void> call(String commerceId, String invitationId) =>
      _repository.cancelInvitation(commerceId, invitationId);
}
