import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/constant/const.dart';
import 'package:ts_autoparts_app/screens/customer/rate_review_screen.dart';
import 'package:ts_autoparts_app/models/product.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'User not logged in.';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/api/orders');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allOrders = json.decode(response.body);
        print('=== DEBUG: Orders Response ===');
        print('Total orders: ${allOrders.length}');

        final List<dynamic> activeOrders = allOrders.where((order) {
          final status = (order['status'] ?? '').toString().toLowerCase();
          return status != 'cancelled' && status != 'canceled';
        }).toList();

        // Fetch reviews for all products in delivered orders
        for (var order in activeOrders) {
          if ((order['status'] ?? '').toString().toLowerCase() == 'delivered') {
            final orderItems = order['order_items'] as List<dynamic>? ?? [];
            print('=== DEBUG: Order Items ===');
            print(json.encode(orderItems));
            for (var item in orderItems) {
              try {
                final productId = item['product_id'];
                final reviewResponse = await http.get(
                  Uri.parse('$baseUrl/api/reviews/product/$productId'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                );

                if (reviewResponse.statusCode == 200) {
                  final List<dynamic> reviews = json.decode(reviewResponse.body);
                  final userId = await SecureStorage.getUserId();
                  final hasUserReview = reviews.any((review) => review['user_id'] == userId);
                  item['has_review'] = hasUserReview;
                }
              } catch (e) {
                print('Error checking review for product ${item['product_id']}: $e');
              }
            }
            order['products'] = orderItems.map((item) => {
              'id': item['product_id'] ?? 0,
              'name': item['product']['name'] ?? '',
              'brand': item['product']['brand'] ?? '',
              'model': item['product']['model'] ?? '',
              'image_url': item['product']['image_url'],
              'has_review': item['has_review'] ?? false,
            }).toList();
          }
        }

        setState(() {
          _orders = activeOrders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load orders. (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/orders/$orderId/cancel');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _orders.removeWhere((order) => order['id'] == orderId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cannot be cancelled at this stage')),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _navigateToRateReview(dynamic order, dynamic product) async {
    final productObj = Product(
      id: product['id'],
      name: product['name'] ?? '',
      brand: product['brand'] ?? '',
      model: product['model'] ?? '',
      price: 0.0,
      image_url: product['image_url'],
      description: '',
      averageRating: null,
      reviewCount: null,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateReviewScreen(
          product: productObj,
          orderId: order['id'],
        ),
      ),
    );

    if (result == true) {
      // Refresh orders to update review status
      _fetchOrders();
    }
  }

  String capitalizeStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF144FAB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _orders.isEmpty
                  ? const Center(child: Text('You have no orders.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final status = (order['status'] ?? 'unknown').toString().toLowerCase();
                        final total = double.tryParse(order['total_amount'].toString())?.toStringAsFixed(2) ?? '0.00';
                        final date = order['order_date'] ?? 'N/A';
                        final products = order['products'] as List<dynamic>? ?? [];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              // Order Header
                              ListTile(
                                leading: const Icon(Icons.shopping_cart, color: Color(0xFF144FAB)),
                                title: Text('Order #${order['id']}'),
                                subtitle: Text(
                                  'Date: $date\n'
                                  'Status: ${capitalizeStatus(status)}\n'
                                  'Total: \$$total',
                                ),
                                isThreeLine: true,
                                trailing: (status == 'canceled' || status == 'cancelled')
                                    ? const Text('Canceled', style: TextStyle(color: Colors.red))
                                    : TextButton(
                                        onPressed: () => _cancelOrder(order['id']),
                                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                      ),
                              ),
                              // Products Section for Delivered Orders
                              if (status == 'delivered' && products.isNotEmpty) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Products',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...products.map((product) {
                                        final hasReview = product['has_review'] ?? false;
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            leading: product['image_url'] != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Image.network(
                                                      product['image_url'],
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.image, size: 50);
                                                      },
                                                    ),
                                                  )
                                                : const Icon(Icons.image, size: 50),
                                            title: Text(
                                              product['name'],
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text('Brand: ${product['brand']}'),
                                            trailing: hasReview
                                                ? Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[50],
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.green),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Reviewed',
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : TextButton.icon(
                                                    onPressed: () => _navigateToRateReview(order, product),
                                                    icon: const Icon(Icons.star_border, size: 18),
                                                    label: const Text('Rate & Review'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: primaryColor,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
