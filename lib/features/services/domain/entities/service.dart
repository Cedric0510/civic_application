class Service {
  const Service({
    required this.id,
    required this.name,
    this.description,
    this.email,
    this.phone,
    this.address,
    this.hours,
    this.category,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final String? hours;
  final String? category;
  final String? imageUrl;
}
