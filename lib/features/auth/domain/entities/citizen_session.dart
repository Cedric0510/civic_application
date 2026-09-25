import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:equatable/equatable.dart';

enum CitizenRole {
  user('USER'),
  commercant('COMMERCANT');

  const CitizenRole(this.apiValue);

  final String apiValue;

  static CitizenRole fromApiValue(String value) {
    return CitizenRole.values.firstWhere(
      (role) => role.apiValue == value,
      orElse: () => CitizenRole.user,
    );
  }
}

class ManagedCommerceRef extends Equatable {
  const ManagedCommerceRef({
    required this.id,
    required this.name,
    this.isChief = false,
  });

  final String id;
  final String name;
  final bool isChief;

  factory ManagedCommerceRef.fromJson(Map<String, dynamic> json) {
    return ManagedCommerceRef(
      id: json['id'] as String,
      name: json['name'] as String,
      isChief: json['isChief'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, isChief];
}

// Identité de session du citoyen connecté : sa commune (pilote tout le
// contenu affiché) et, s'il est commerçant, le commerce qu'il gère en
// autonomie.
class CitizenSession extends Equatable {
  const CitizenSession({
    required this.commune,
    required this.role,
    this.managedCommerce,
    this.voteEligibleAt,
  });

  final CommuneRef commune;
  final CitizenRole role;
  final ManagedCommerceRef? managedCommerce;

  // Null tant que civic_api n'a pas pu être interrogé (repli hors ligne) :
  // on ne bloque alors pas l'interface, le serveur reste l'arbitre du vote.
  final DateTime? voteEligibleAt;

  bool get isCommercant =>
      role == CitizenRole.commercant && managedCommerce != null;

  bool canVoteAt(DateTime now) =>
      voteEligibleAt == null || !now.isBefore(voteEligibleAt!);

  @override
  List<Object?> get props => [commune, role, managedCommerce, voteEligibleAt];
}
