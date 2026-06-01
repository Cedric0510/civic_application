class Service {
  const Service({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.address,
    this.hours,
    this.category,
  });

  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? address;
  final String? hours;
  final String? category;
}
