import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/constant/const.dart';

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

        final List<dynamic> activeOrders = allOrders.where((order) {
          final status = (order['status'] ?? '').toString().toLowerCase();
          return status != 'cancelled' && status != 'canceled';
        }).toList();

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
          const SnackBar(content: Text('Failed to cancel order.')),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
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
  );
},

                      
                    ),
    );
  }
}
