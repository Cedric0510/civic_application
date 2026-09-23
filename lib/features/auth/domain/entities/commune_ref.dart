import 'package:equatable/equatable.dart';

// Référence légère à une commune (id/nom/slug), utilisée à deux endroits :
// la commune du citoyen connecté (résout tout le contenu affiché dans
// l'appli) et la liste publique des communes partenaires proposée au
// moment de l'inscription.
class CommuneRef extends Equatable {
  const CommuneRef({required this.id, required this.name, required this.slug});

  final String id;
  final String name;
  final String slug;

  factory CommuneRef.fromJson(Map<String, dynamic> json) {
    return CommuneRef(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}
