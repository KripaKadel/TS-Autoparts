import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/models/product.dart'; // Import the Product model
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ts_autoparts_app/utils/secure_storage.dart'; // Import the SecureStorage class

class ProductDescriptionPage extends StatefulWidget {
  final Product product;
  const ProductDescriptionPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  int quantity = 1;
  double rating = 3.4;
  double userRating = 0;

  // Method to add product to cart
  Future<void> addToCart(Product product, int quantity) async {
    // Retrieve the token from secure storage
    String? token = await SecureStorage.getToken();

    if (token == null) {
      // If token is null, show error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Authentication failed. Please login first.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/cart/add');
    
    // Debug log for the request
    print("Adding product to cart: product_id=${product.id}, quantity=$quantity");

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Add token to Authorization header
      },
      body: jsonEncode(<String, dynamic>{
        'product_id': product.id,
        'quantity': quantity,
      }),
    );

    // Handle the response
    if (response.statusCode == 200) {
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added to Cart Successfully!'),
        backgroundColor: Colors.green,
      ));
      print("Product added to cart successfully!");
    } else {
      // Failure message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add product to cart!'),
        backgroundColor: Colors.red,
      ));
      print("Failed to add product to cart. Error: ${response.statusCode}");
    }
  }

  // Method to handle star rating
  void _onRatingUpdate(double value) {
    setState(() {
      userRating = value;
    });
    // Here you would typically send this rating to your backend
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('You rated this product ${value.toInt()} stars!'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Add rating to app bar on the same line as back arrow
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text(
                  '$rating',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Image on Light Grey Background
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[100],
              child: Center(
                child: widget.product.image_url != null
                    ? Image.network(
                        widget.product.image_url!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 50, color: Colors.red);
                        },
                      )
                    : Icon(Icons.image, size: 50, color: Colors.grey[700]),
              ),
            ),
            
            // White Container for Product Details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Interactive Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Interactive five stars rating
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => _onRatingUpdate(index + 1.0),
                            child: Icon(
                              index < userRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Price
                  Text(
                    'Rs. ${widget.product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Brand
                  Text(
                    'Brand: ${widget.product.brand}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Product Description
                  Text(
                    widget.product.description ?? 'Product description unavailable.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            // Minus Button
                            InkWell(
                              onTap: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Icon(Icons.remove, color: Colors.red, size: 18),
                              ),
                            ),
                            // Quantity Display
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$quantity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Plus Button
                            InkWell(
                              onTap: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Icon(Icons.add, color: Colors.green, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        addToCart(widget.product, quantity);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[0xFF144FAB],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add To Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}