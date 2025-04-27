import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ts_autoparts_app/models/cart.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/function/esewa.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<String> pokharaLocations = [
    'Lakeside','Nayabazar','Prithvi Chowk','Mahendrapool','Newroad','Shantiban','Hospital Chowk','Siddhartha Chowk','Bagar','Srijana Chowk'
  ];

  String? _selectedLocation; 
  List<CartItem> cartItems = [];
  bool isLoading = true;
  double totalAmount = 0.0;
  bool isProcessingPayment = false;
  final Color primaryColor = const Color(0xFF144FAB);
  TextEditingController _addressController = TextEditingController();
  String _deliveryAddress = '';

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);
    final token = await SecureStorage.getToken();

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token is missing!')),
        );
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/cart');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> cartItemsData = data['cart_items'];

        if (mounted) {
          setState(() {
            cartItems = cartItemsData.map((item) => CartItem.fromJson(item)).toList();
            totalAmount = data['total_amount']?.toDouble() ?? 0.0;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token is missing!')),
        );
      }
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/cart/update/$cartItemId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'quantity': newQuantity
        }),
      );

      if (response.statusCode == 200) {
        await fetchCartItems();
      } else {
        throw Exception('Failed to update quantity: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> removeItemFromCart(int cartItemId) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token is missing!')),
        );
      }
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/cart/remove/$cartItemId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchCartItems();
      } else {
        throw Exception('Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

 void _showAddressDialog() {
  if (cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your cart is empty!')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Select Delivery Location', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select your location in Pokhara'),
                value: _selectedLocation,
                underline: SizedBox(), // Remove default underline
                items: pokharaLocations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'We only deliver inside Pokhara.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (_selectedLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a delivery location')),
                );
                return;
              }
              setState(() {
                _deliveryAddress = _selectedLocation!;
              });
              Navigator.pop(context);
              _showPaymentDialog();
            },
            child: const Text('Continue', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

  void _showPaymentDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Delivery to:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(_deliveryAddress, 
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
              SizedBox(height: 16),
              const Text('Total Amount:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Rs.${totalAmount.toStringAsFixed(2)}', 
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Rs.${totalAmount.toStringAsFixed(2)}', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Including all taxes and charges', 
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                _initiateEsewaPayment();
              },
              child: const Text('Pay with eSewa', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiateEsewaPayment() async {
    if (cartItems.isEmpty) return;

    setState(() => isProcessingPayment = true);

    try {
      final referenceId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
      
      Esewa(
        context: context,
        productName: 'Cart Checkout - ${cartItems.length} items',
        amount: totalAmount,
        onSuccess: () async {
          try {
            await _createOrder(referenceId);
            if (mounted) {
              setState(() => isProcessingPayment = false);
              _showSuccessDialog(totalAmount);
              await _clearCart();
            }
          } catch (e) {
            if (mounted) {
              setState(() => isProcessingPayment = false);
              _showErrorSnackBar('Order creation failed: ${e.toString()}');
            }
          }
        },
        onFailure: () {
          if (mounted) {
            setState(() => isProcessingPayment = false);
            _showErrorSnackBar('Payment failed. Please try again.');
          }
        },
        onCancel: () {
          if (mounted) {
            setState(() => isProcessingPayment = false);
            _showErrorSnackBar('Payment cancelled.');
          }
        },
      ).pay();
    } catch (e) {
      if (mounted) {
        setState(() => isProcessingPayment = false);
        _showErrorSnackBar('Payment error: ${e.toString()}');
      }
    }
  }

  Future<void> _processOrderPayment(int orderId, String transactionId) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final paymentUrl = Uri.parse('http://10.0.2.2:8000/api/orders/$orderId/payment');
      debugPrint('Sending payment request to: $paymentUrl');
      
      final paymentData = {
        'payment_method': 'esewa',
        'transaction_id': transactionId,
        'payment_details': {
          'payment_type': 'order',
          'items_count': cartItems.length,
          'delivery_address': _deliveryAddress,
          'items': cartItems.map((item) => {
            'product_id': item.product.id,
            'name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
        },
      };
      
      debugPrint('Payment request body: ${jsonEncode(paymentData)}');

      final response = await http.post(
        paymentUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(paymentData),
      );

      debugPrint('Payment response status code: ${response.statusCode}');
      debugPrint('Payment response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Parsed payment response: $responseData');
        
        if (responseData['status'] == true) {
          return;
        } else {
          throw Exception('Payment failed: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = jsonDecode(response.body);
        final errors = errorData['errors'] ?? {};
        final errorMessages = errors.values.join(', ');
        throw Exception('Validation error: $errorMessages');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Payment failed with status ${response.statusCode}: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Payment processing error: $e');
      if (e is FormatException) {
        debugPrint('Invalid JSON response from server');
      }
      rethrow;
    }
  }

  Future<void> _createOrder(String referenceId) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final List<Map<String, dynamic>> orderItems = cartItems.map((item) {
        return {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      final orderData = {
        'payment_reference': referenceId,
        'total_amount': totalAmount,
        'order_items': orderItems,
        'delivery_address': _deliveryAddress,
      };

      // First create the order
      final createOrderUrl = Uri.parse('http://10.0.2.2:8000/api/orders/create');
      debugPrint('Sending order creation request to: $createOrderUrl');
      debugPrint('Order request body: ${jsonEncode(orderData)}');

      final orderResponse = await http.post(
        createOrderUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      debugPrint('Order creation response status code: ${orderResponse.statusCode}');
      debugPrint('Order creation response body: ${orderResponse.body}');
      
      if (orderResponse.statusCode == 201) {
        final orderResponseData = jsonDecode(orderResponse.body);
        debugPrint('Parsed order response: $orderResponseData');
        
        // Check for both possible response formats
        final int? orderId = orderResponseData['id'] ?? 
                           orderResponseData['order']?['id'] ?? 
                           (orderResponseData['data']?['id'] as int?);

        if (orderId != null) {
          await _processOrderPayment(orderId, referenceId);
          return;
        } else {
          debugPrint('Response structure: ${orderResponseData.keys.join(', ')}');
          throw Exception('Invalid order response format: Missing order ID. Response: ${orderResponse.body}');
        }
      } else if (orderResponse.statusCode == 422) {
        // Validation error
        final errorData = jsonDecode(orderResponse.body);
        final errors = errorData['errors'] ?? {};
        final errorMessages = errors.values.join(', ');
        throw Exception('Validation error: $errorMessages');
      } else {
        final errorData = jsonDecode(orderResponse.body);
        throw Exception('Order creation failed with status ${orderResponse.statusCode}: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Order creation error: $e');
      if (e is FormatException) {
        debugPrint('Invalid JSON response from server');
      }
      rethrow;
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) return;

      final url = Uri.parse('http://10.0.2.2:8000/api/cart/clear');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (mounted) {
        setState(() {
          cartItems.clear();
          totalAmount = 0.0;
          _addressController.clear();
          _deliveryAddress = '';
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to clear cart: ${e.toString()}');
      }
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Order Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs.${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle commonTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue[900],
      fontSize: 18,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (cartItems.isEmpty)
            Center(child: Text('Your cart is empty!'))
          else
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: item.product.image_url != null
                                  ? Image.network(
                                      item.product.image_url!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image, size: 50),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    item.product.brand ?? 'Brand',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${item.product.price.toStringAsFixed(2)}',
                                    style: commonTextStyle,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        updateCartItemQuantity(item.id, item.quantity - 1);
                                      }
                                    },
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      updateCartItemQuantity(item.id, item.quantity + 1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeItemFromCart(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Rs.',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cartItems.isEmpty 
                            ? null 
                            : _showAddressDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (isProcessingPayment)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}