import 'package:civic_app/features/commerces/data/datasources/commerce_team_api_datasource.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';

class CommerceTeamRepositoryImpl implements CommerceTeamRepository {
  const CommerceTeamRepositoryImpl(this._datasource);

  final CommerceTeamApiDatasource _datasource;

  @override
  Future<CommerceTeam> getTeam(String commerceId) =>
      _datasource.getTeam(commerceId);

  @override
  Future<TeamAddOutcome> addMember(String commerceId, String email) =>
      _datasource.addMember(commerceId, email);

  @override
  Future<void> removeMember(String commerceId, String memberId) =>
      _datasource.removeMember(commerceId, memberId);

  @override
  Future<void> cancelInvitation(String commerceId, String invitationId) =>
      _datasource.cancelInvitation(commerceId, invitationId);
}
