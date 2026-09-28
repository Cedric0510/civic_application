import 'package:equatable/equatable.dart';

// Référence légère à une commune (id/nom/slug), utilisée à deux endroits :
// la commune du citoyen connecté (résout tout le contenu affiché dans
// l'appli) et la liste publique des communes partenaires proposée au
// moment de l'inscription.
class CommuneRef extends Equatable {
  const CommuneRef({
    required this.id,
    required this.name,
    required this.slug,
    this.postalCode,
  });

  final String id;
  final String name;
  final String slug;

  // Non nul sur la liste publique (/communes/public), sert à rattacher un
  // nouveau compte à sa commune sans liste déroulante -- cf. AuthPage.
  // Absent de la commune du citoyen connecté (/citizens/me), inutile là.
  final String? postalCode;

  factory CommuneRef.fromJson(Map<String, dynamic> json) {
    return CommuneRef(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      postalCode: json['postalCode'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, postalCode];
}
