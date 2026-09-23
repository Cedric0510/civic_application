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

  // Champs modifiables via PATCH /commerces/:id -- le même DTO civic_api
  // accepte staff et commerçant, cf. CommercesService.update.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'email': email,
      'phone': phone,
      'address': address,
      'hours': hours,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }
}
