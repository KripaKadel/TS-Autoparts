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
  List<dynamic> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _filterOrders() {
    if (_selectedStatus == null || _selectedStatus == 'All') {
      _filteredOrders = _orders.map((order) {
        if (order['status']?.toString().toLowerCase() == 'canceled') {
          order['status'] = 'cancelled';
        }
        return order;
      }).toList();
    } else {
      _filteredOrders = _orders.where((order) {
        String orderStatus = order['status']?.toString().toLowerCase() ?? '';
        if (orderStatus == 'canceled') {
          orderStatus = 'cancelled';
          order['status'] = 'cancelled';
        }
        return orderStatus == _selectedStatus!.toLowerCase();
      }).toList();
    }
    setState(() {});
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

        setState(() {
          _orders = allOrders;
          _filterOrders();
          _isLoading = false;
        });

        // Fetch reviews for delivered orders
        for (var order in allOrders) {
          if ((order['status'] ?? '').toString().toLowerCase() == 'delivered') {
            final orderItems = order['order_items'] as List<dynamic>? ?? [];
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
        _filterOrders();
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

  Future<void> _onRefresh() {
    return _fetchOrders();
  }

  bool _isOrderFullyReviewed(dynamic order) {
    if (order['products'] == null) return false;
    final products = order['products'] as List<dynamic>;
    return products.every((product) => product['has_review'] == true);
  }

  Color _getOrderBackgroundColor(dynamic order, String status) {
    if (status.toLowerCase() == 'delivered' && _isOrderFullyReviewed(order)) {
      return Colors.green.shade50;
    }
    return Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF144FAB);
    final Color secondaryTextColor = Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      hint: const Text('Filter by Status'),
                      isExpanded: true,
                      items: _statusFilters.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status == 'All' ? null : status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                          _filterOrders();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: secondaryTextColor),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchOrders,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filteredOrders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedStatus == null ? Icons.shopping_bag_outlined : Icons.filter_list,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedStatus == null
                                        ? 'No orders yet'
                                        : 'No $_selectedStatus orders found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedStatus == null
                                        ? 'Your order history will appear here'
                                        : 'Try selecting a different filter',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                final status = order['status'] ?? 'Unknown';
                                final isDelivered = status.toLowerCase() == 'delivered';
                                final isReviewed = _isOrderFullyReviewed(order);
                                final orderItems = order['order_items'] as List<dynamic>? ?? [];
                                final totalAmount = order['total_amount']?.toString() ?? '0';
                                final orderDate = order['created_at'] ?? 'N/A';

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isDelivered && isReviewed
                                          ? Colors.green.shade200
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _getOrderBackgroundColor(order, status),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
  orderItems.isNotEmpty 
    ? (orderItems.length == 1 
        ? orderItems.first['product']['name'] ?? 'Product'
        : '${orderItems.first['product']['name']} + ${orderItems.length - 1} more')
    : 'No products',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),
                                                      if (isDelivered && isReviewed) ...[
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green.shade100,
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(
                                                                Icons.check_circle,
                                                                size: 14,
                                                                color: Colors.green.shade700,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                'Reviewed',
                                                                style: TextStyle(
                                                                  color: Colors.green.shade700,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Placed on $orderDate',
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _getStatusColor(status),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                capitalizeStatus(status),
                                                style: TextStyle(
                                                  color: _getStatusColor(status),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Items',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...orderItems.map((item) => Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${item['quantity']}x',
                                                      style: TextStyle(
                                                        color: primaryColor,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      item['product']['name'],
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Total Amount',
                                                  style: TextStyle(
                                                    color: secondaryTextColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Rs. $totalAmount',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (!isDelivered && status.toLowerCase() != 'cancelled') ...[
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () => _cancelOrder(order['id']),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.red,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                    ),
                                                    child: const Text('Cancel Order'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isDelivered && order['products'] != null) ...[
                                        const Divider(height: 1),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(Icons.star_border, size: 20),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Ratings & Reviews',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              ...List<Widget>.from(
                                                (order['products'] as List<dynamic>).map(
                                                  (product) => Container(
                                                    margin: const EdgeInsets.only(bottom: 8),
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[50],
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.grey[200]!),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        if (product['image_url'] != null)
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(6),
                                                            child: Image.network(
                                                              product['image_url'],
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) =>
                                                                  Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    color: Colors.grey[200],
                                                                    child: const Icon(Icons.image, color: Colors.grey),
                                                                  ),
                                                            ),
                                                          )
                                                        else
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[200],
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: const Icon(Icons.image, color: Colors.grey),
                                                          ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                product['name'],
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                product['brand'],
                                                                style: TextStyle(
                                                                  color: secondaryTextColor,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        product['has_review'] == true
                                                            ? Container(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 12,
                                                                  vertical: 6,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.green[50],
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  border: Border.all(color: Colors.green),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: const [
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
                                                                        fontWeight: FontWeight.w500,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : TextButton.icon(
                                                                onPressed: () =>
                                                                    _navigateToRateReview(order, product),
                                                                icon: const Icon(Icons.star_border, size: 18),
                                                                label: const Text('Rate & Review'),
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor: primaryColor,
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 16,
                                                                    vertical: 8,
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
