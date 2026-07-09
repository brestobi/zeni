/// Rating and review for a completed ride.
class Rating {
  final String id;
  final String rideId;
  final String reviewerId;
  final String reviewedId;
  final int score;
  final String? review;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.rideId,
    required this.reviewerId,
    required this.reviewedId,
    required this.score,
    this.review,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        id: json['id'] as String,
        rideId: json['ride_id'] as String,
        reviewerId: json['reviewer_id'] as String,
        reviewedId: json['reviewed_id'] as String,
        score: json['score'] as int,
        review: json['review'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ride_id': rideId,
        'reviewer_id': reviewerId,
        'reviewed_id': reviewedId,
        'score': score,
        'review': review,
        'created_at': createdAt.toIso8601String(),
      };
}
