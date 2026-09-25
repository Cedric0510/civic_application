import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/commerces/data/models/commerce_team_model.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';

class CommerceTeamApiDatasource {
  const CommerceTeamApiDatasource(this._api);

  final ApiClient _api;

  Future<CommerceTeam> getTeam(String commerceId) async {
    final members =
        await _api.get('/commerces/$commerceId/managers') as List<dynamic>;
    final invitations =
        await _api.get('/commerces/$commerceId/invitations') as List<dynamic>;
    return CommerceTeam(
      members: members
          .map(
            (item) =>
                CommerceTeamMemberModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      invitations: invitations
          .map(
            (item) =>
                CommerceInvitationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<TeamAddOutcome> addMember(String commerceId, String email) async {
    final json =
        await _api.post('/commerces/$commerceId/managers', {'email': email})
            as Map<String, dynamic>;
    return json['status'] == 'linked'
        ? TeamAddOutcome.linked
        : TeamAddOutcome.invited;
  }

  Future<void> removeMember(String commerceId, String memberId) async {
    await _api.delete('/commerces/$commerceId/managers/$memberId');
  }

  Future<void> cancelInvitation(String commerceId, String invitationId) async {
    await _api.delete('/commerces/$commerceId/invitations/$invitationId');
  }
}
