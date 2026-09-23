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
  const ManagedCommerceRef({required this.id, required this.name});

  final String id;
  final String name;

  factory ManagedCommerceRef.fromJson(Map<String, dynamic> json) {
    return ManagedCommerceRef(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

// Identité de session du citoyen connecté : sa commune (pilote tout le
// contenu affiché, cf. docs/ROADMAP.md) et, s'il est commerçant, le
// commerce qu'il gère en autonomie -- cf. Décision "Rôle commerçant"
// (2026-09-23).
class CitizenSession extends Equatable {
  const CitizenSession({
    required this.commune,
    required this.role,
    this.managedCommerce,
  });

  final CommuneRef commune;
  final CitizenRole role;
  final ManagedCommerceRef? managedCommerce;

  bool get isCommercant =>
      role == CitizenRole.commercant && managedCommerce != null;

  @override
  List<Object?> get props => [commune, role, managedCommerce];
}
