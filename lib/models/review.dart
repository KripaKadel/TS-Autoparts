class Review {
  final int id;
  final int userId;
  final int? productId;
  final int? mechanicId;
  final double rating;
  final String? comment;
  final String userName;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    this.productId,
    this.mechanicId,
    required this.rating,
    this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return Review(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int?,
      mechanicId: json['mechanic_id'] as int?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      userName: user['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'mechanic_id': mechanicId,
      'rating': rating,
      'comment': comment,
    };
  }
} 