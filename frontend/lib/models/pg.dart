class PG {
  final int id;
  final String name;
  final String address;
  final int rent;
  final bool foodIncluded;
  final String gender;
  final double rating;
  final double? distance;
  final String? image;

  PG({
    required this.id,
    required this.name,
    required this.address,
    required this.rent,
    required this.foodIncluded,
    required this.gender,
    required this.rating,
    this.distance,
    this.image,
  });

  factory PG.fromJson(Map<String, dynamic> json) {
    return PG(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? 'No address',
      rent: _parseRent(json['one_month_rent'] ?? json['monthly_rent']),
      foodIncluded: json['food_included'] ?? json['mess_available'] ?? false,
      gender: json['gender'] ?? 'Any',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: json['distance']?.toDouble(),
      image: json['image'],
    );
  }

  static int _parseRent(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      // Remove ₹ and commas, then extract numbers
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
}
