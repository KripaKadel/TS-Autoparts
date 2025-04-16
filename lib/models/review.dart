class Review {
  final int id;
  final int mechanicId;
  final int userId;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.mechanicId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      mechanicId: json['mechanic_id'],
      userId: json['user_id'],
      userName: json['user']['name'] ?? 'Anonymous',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mechanic_id': mechanicId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 