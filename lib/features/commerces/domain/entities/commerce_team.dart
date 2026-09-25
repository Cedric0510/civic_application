import 'package:equatable/equatable.dart';

class CommerceTeamMember extends Equatable {
  const CommerceTeamMember({
    required this.id,
    required this.email,
    required this.isChief,
  });

  final String id;
  final String email;
  final bool isChief;

  @override
  List<Object?> get props => [id, email, isChief];
}

class CommerceInvitation extends Equatable {
  const CommerceInvitation({
    required this.id,
    required this.email,
    required this.expiresAt,
  });

  final String id;
  final String email;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [id, email, expiresAt];
}

class CommerceTeam extends Equatable {
  const CommerceTeam({required this.members, required this.invitations});

  final List<CommerceTeamMember> members;
  final List<CommerceInvitation> invitations;

  @override
  List<Object?> get props => [members, invitations];
}

enum TeamAddOutcome { linked, invited }
