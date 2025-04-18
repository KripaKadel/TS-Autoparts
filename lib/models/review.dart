class Review {
  final int id;
  final int? mechanicId;
  final int? productId;
  final int userId;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    this.mechanicId,
    this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      mechanicId: json['mechanic_id'] as int?,
      productId: json['product_id'] as int?,
      userId: json['user_id'] as int,
      userName: json['user']?['name'] ?? 'Anonymous',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mechanic_id': mechanicId,
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 