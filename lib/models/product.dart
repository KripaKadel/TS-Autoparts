class Product {
  final int id;
  final String name;
  final String brand;
  final String model;
  final double price;
  final String? image; // Relative image path (e.g., "product_images/filename.jpg")
  final String? image_url; // Full image URL (e.g., "http://192.168.1.71:8000/storage/product_images/filename.jpg")
  final String? description; // Product description
  final double? averageRating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.price,
    this.image,
    this.image_url,
    this.description,
    this.averageRating,
    this.reviewCount,
  });

  // Factory constructor to parse JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int, // Ensure the ID is an integer
      name: (json['name'] as String?) ?? '', // Handle null name
      brand: (json['brand'] as String?) ?? '', // Handle null brand
      model: (json['model'] as String?) ?? '', // Handle null model
      price: _parsePrice(json['price']), // Parse the price (handles both string and double)
      image: json['image'] as String?, // Relative image path (nullable)
      image_url: json['image_url'] as String?, // Full image URL (nullable)
      description: json['description'] as String?, // Product description (nullable)
      averageRating: json['average_rating'] != null ? (json['average_rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
    );
  }

  // Helper method to parse price (handles both string and double)
  static double _parsePrice(dynamic price) {
    if (price is String) {
      return double.parse(price); // Convert string to double
    } else if (price is double) {
      return price; // Return as-is if already a double
    } else if (price is int) {
      return price.toDouble(); // Convert int to double
    } else {
      throw FormatException('Invalid price format: $price');
    }
  }

  // Convert Product object to JSON (optional, if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'price': price,
      'image': image,
      'image_url': image_url,
      'description': description,
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
  }

  // Override toString() for better debugging
  @override
  String toString() {
    return 'Product(id: $id, name: $name, brand: $brand,model: $model, price: $price, image: $image, image_url: $image_url, description: $description, averageRating: $averageRating, reviewCount: $reviewCount)';
  }
}