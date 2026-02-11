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

  /// S3.4: Defensive deserialization with coordinate validation
  /// and category fallback.
  factory ToledoSpot.fromJson(Map<String, dynamic> json) {
    // Validate coordinates
    final lat = (json['latitude'] as num).toDouble().clamp(-90.0, 90.0);
    final lng = (json['longitude'] as num).toDouble().clamp(-180.0, 180.0);

    // Safe category lookup with fallback
    SpotCategory category;
    try {
      category = SpotCategory.values.byName(json['category'] as String);
    } catch (_) {
      category = SpotCategory.entertainment;
    }

    return ToledoSpot(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: lat,
      longitude: lng,
      category: category,
      vibeCheck: json['vibeCheck'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] as String?,
    );
  }
}
