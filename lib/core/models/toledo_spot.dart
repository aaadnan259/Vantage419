import 'spot_category.dart';

/// A discoverable location in Toledo.
class ToledoSpot {
  const ToledoSpot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.vibeCheck,
    required this.description,
    this.imageUrl,
    this.address,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final SpotCategory category;
  final String vibeCheck;
  final String description;
  final String? imageUrl;
  final String? address;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'category': category.name,
    'vibeCheck': vibeCheck,
    'description': description,
    'imageUrl': imageUrl,
    'address': address,
  };

  factory ToledoSpot.fromJson(Map<String, dynamic> json) => ToledoSpot(
    id: json['id'] as String,
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    category: SpotCategory.values.byName(json['category'] as String),
    vibeCheck: json['vibeCheck'] as String,
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String?,
    address: json['address'] as String?,
  );
}
