import 'package:civic_app/features/services/domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.name,
    super.description,
    super.email,
    super.phone,
    super.address,
    super.hours,
    super.category,
    super.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      hours: json['hours'] as String?,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
