import 'package:civic_app/features/reports/domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    super.id,
    required super.address,
    required super.category,
    required super.description,
    super.imageUrl,
    super.status,
    super.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String?,
      address: json['address'] as String,
      category: ReportCategory.fromApiValue(json['category'] as String),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] != null
          ? ReportStatus.fromApiValue(json['status'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // Seuls les champs attendus par POST /reports : citizenId/communeId sont
  // dérivés du JWT côté civic_api, status/createdAt sont déterminés par lui.
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'category': category.apiValue,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
