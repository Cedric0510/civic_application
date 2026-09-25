import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';

class CommerceTeamMemberModel extends CommerceTeamMember {
  const CommerceTeamMemberModel({
    required super.id,
    required super.email,
    required super.isChief,
  });

  factory CommerceTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return CommerceTeamMemberModel(
      id: json['id'] as String,
      email: json['email'] as String,
      isChief: json['isChief'] as bool? ?? false,
    );
  }
}

class CommerceInvitationModel extends CommerceInvitation {
  const CommerceInvitationModel({
    required super.id,
    required super.email,
    required super.expiresAt,
  });

  factory CommerceInvitationModel.fromJson(Map<String, dynamic> json) {
    return CommerceInvitationModel(
      id: json['id'] as String,
      email: json['email'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
