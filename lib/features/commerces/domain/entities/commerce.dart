class Commerce {
  const Commerce({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.email,
    this.phone,
    this.address,
    this.hours,
    this.imageUrl,
    this.notes,
  });

  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final String? hours;
  final String? imageUrl;

  // Annonce publique tenue à jour par le commerçant/la mairie (congés,
  // promotion du moment...) -- cf. docs/ROADMAP.md Décision 6.
  final String? notes;
}
