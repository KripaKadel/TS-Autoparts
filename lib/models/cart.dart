import 'product.dart';  // Ensure you have your Product model here

class CartItem {
  final int id;
  final int userId;
  final Product product;
  final int quantity;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,  // Default to 0 if missing
      userId: json['user_id'] ?? 0,  // Default to 0 if missing
      product: Product.fromJson(json['product'] ?? {}),  // Default to empty if product is missing
      quantity: json['quantity'] ?? 1,  // Default to 1 if quantity is missing
      totalPrice: (json['total_price'] is String
          ? double.tryParse(json['total_price']) ?? 0.0
          : json['total_price']?.toDouble()) ?? 0.0,  // Default to 0.0 if missing or invalid
    );
  }
}
