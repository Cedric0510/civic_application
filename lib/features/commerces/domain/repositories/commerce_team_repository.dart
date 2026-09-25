import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';

abstract class CommerceTeamRepository {
  Future<CommerceTeam> getTeam(String commerceId);
  Future<TeamAddOutcome> addMember(String commerceId, String email);
  Future<void> removeMember(String commerceId, String memberId);
  Future<void> cancelInvitation(String commerceId, String invitationId);
}
