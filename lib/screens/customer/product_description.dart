import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/models/product.dart'; // Import the Product model
import 'package:ts_autoparts_app/models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ts_autoparts_app/utils/secure_storage.dart'; // Import the SecureStorage class
import 'package:ts_autoparts_app/constant/const.dart';
import 'package:flutter/foundation.dart';

class ProductDescriptionPage extends StatefulWidget {
  final Product product;
  const ProductDescriptionPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  int quantity = 1;
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  String? _reviewError;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/${widget.product.id}/reviews'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Reviews response status: ${response.statusCode}');
      debugPrint('Reviews response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = json.decode(response.body);
        final reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();
        
        // Calculate average rating
        double totalRating = 0;
        for (var review in reviews) {
          totalRating += review.rating;
        }
        
        setState(() {
          _reviews = reviews;
          _averageRating = reviews.isEmpty ? 0.0 : totalRating / reviews.length;
          _isLoadingReviews = false;
        });
      } else {
        setState(() {
          _reviewError = 'Failed to load reviews: ${response.statusCode}';
          _isLoadingReviews = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading reviews: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _reviewError = 'Error loading reviews: $e';
        _isLoadingReviews = false;
      });
    }
  }

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

    final url = Uri.parse('$baseUrl/api/cart/add');
    
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

  Widget _buildReviewItem(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  review.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(review.rating.toString()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment ?? 'No comment provided'),
            const SizedBox(height: 8),
            Text(
              'Reviewed on ${review.createdAt.toString().split(' ')[0]}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_reviewError!),
            ElevatedButton(
              onPressed: _fetchReviews,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewItem(review);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (_reviews.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${_reviews.length})',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          return const Icon(Icons.error, size: 50, color: Colors.red);
                        },
                      )
                    : Icon(Icons.image, size: 50, color: Colors.grey[700]),
              ),
            ),
            
            // White Container for Product Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Text(
                    'Rs. ${widget.product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Brand
                  Text(
                    'Brand: ${widget.product.brand}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Product Description
                  Text(
                    widget.product.description ?? 'Product description unavailable.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
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
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildReviewsSection(),
            ),
          ],
        ),
      ),
    );
  }
}