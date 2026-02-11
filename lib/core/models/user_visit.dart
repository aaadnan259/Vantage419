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

  /// S3.4: Defensive deserialization — invalid dates fall back to epoch.
  factory UserVisit.fromJson(Map<String, dynamic> json) => UserVisit(
    spotId: json['spotId'] as String? ?? '',
    visitedAt:
        DateTime.tryParse(json['visitedAt']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    rating: json['rating'] as int?,
  );
}
