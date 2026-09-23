import 'package:equatable/equatable.dart';

enum ReportCategory {
  voirie('VOIRIE', 'Voirie'),
  eclairage('ECLAIRAGE', 'Éclairage'),
  proprete('PROPRETE', 'Propreté'),
  espacesVerts('ESPACES_VERTS', 'Espaces verts'),
  autre('AUTRE', 'Autre');

  const ReportCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ReportCategory fromApiValue(String value) {
    return ReportCategory.values.firstWhere(
      (category) => category.apiValue == value,
      orElse: () => ReportCategory.autre,
    );
  }
}

enum ReportStatus {
  nouveau('NOUVEAU', 'Nouveau'),
  enCours('EN_COURS', 'En cours'),
  traite('TRAITE', 'Traité');

  const ReportStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ReportStatus fromApiValue(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => ReportStatus.nouveau,
    );
  }
}

// Signalement citoyen, version simplifiée : ni carte, ni priorité/affectation.
// `status`/`createdAt` sont nuls avant l'envoi -- civic_api les détermine
// (status par défaut, horodatage de réception).
class Report extends Equatable {
  const Report({
    this.id,
    required this.address,
    required this.category,
    required this.description,
    this.imageUrl,
    this.status,
    this.createdAt,
  });

  final String? id;
  final String address;
  final ReportCategory category;
  final String description;
  final String? imageUrl;
  final ReportStatus? status;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    address,
    category,
    description,
    imageUrl,
    status,
    createdAt,
  ];
}
