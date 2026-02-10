/// Tracks a user's visit to a specific spot.
class UserVisit {
  const UserVisit({required this.spotId, required this.visitedAt, this.rating});

  final String spotId;
  final DateTime visitedAt;
  final int? rating;

  Map<String, dynamic> toJson() => {
    'spotId': spotId,
    'visitedAt': visitedAt.toIso8601String(),
    'rating': rating,
  };

  factory UserVisit.fromJson(Map<String, dynamic> json) => UserVisit(
    spotId: json['spotId'] as String,
    visitedAt: DateTime.parse(json['visitedAt'] as String),
    rating: json['rating'] as int?,
  );
}
