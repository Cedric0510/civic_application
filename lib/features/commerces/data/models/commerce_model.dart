import 'package:civic_app/features/commerces/domain/entities/commerce.dart';

class CommerceModel extends Commerce {
  const CommerceModel({
    required super.id,
    required super.name,
    super.category,
    super.description,
    super.email,
    super.phone,
    super.address,
    super.hours,
    super.imageUrl,
    super.notes,
  });

  factory CommerceModel.fromJson(Map<String, dynamic> json) {
    return CommerceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      hours: json['hours'] as String?,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  // Champs modifiables via PATCH /commerces/:id -- même DTO côté civic_api
  // pour le staff (admin_civic) et le commerçant. Un champ nul est omis
  // plutôt qu'envoyé explicitement (mêmes règles que commerceFields() côté
  // admin_civic) : un champ laissé vide dans le formulaire n'efface pas la
  // valeur existante.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (hours != null) 'hours': hours,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (notes != null) 'notes': notes,
    };
  }
}
