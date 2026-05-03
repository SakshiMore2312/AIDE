class College {
  final int id;
  final String name;
  final String type;
  final String address;
  final String fees;
  final double rating;
  final double? distance;
  final String? image; // We might need to add a default image if not in backend

  College({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.fees,
    required this.rating,
    this.distance,
    this.image,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? json['meal_types'] ?? 'General',
      address: json['address'] ?? 'No address',
      fees: json['fees'] ?? json['monthly_charges'] ?? json['fee_structure'] ?? 'N/A',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: json['distance']?.toDouble(),
      image: json['image'],
    );
  }
}
