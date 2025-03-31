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
  List<CartItem> cartItems = [];
  bool isLoading = true;
  double totalAmount = 0.0;
  final Color primaryColor = const Color(0xFF144FAB);

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token is missing!')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/cart');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> cartItemsData = data['cart_items'];

        setState(() {
          cartItems = cartItemsData.map((item) => CartItem.fromJson(item)).toList();
          calculateTotal();
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse cart data!')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart items!')),
      );
    }
  }

  void calculateTotal() {
    totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token is missing!')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/cart/update-quantity');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cart_item_id': cartItemId,
        'quantity': newQuantity
      }),
    );

    if (response.statusCode == 200) {
      fetchCartItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item quantity!')),
      );
    }
  }

  Future<void> removeItemFromCart(int cartItemId) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token is missing!')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/cart/remove');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cart_item_id': cartItemId}),
    );

    if (response.statusCode == 200) {
      fetchCartItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item from cart!')),
      );
    }
  }

  void _showPaymentDialog() {
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
          title: const Text('Cart Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Amount:'),
              const SizedBox(height: 8),
              Text('Rs.${totalAmount.toStringAsFixed(2)}', 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rs.${totalAmount.toStringAsFixed(2)}', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
              ),
              onPressed: () {
                Navigator.pop(context);
                _initiateEsewaPayment();
              },
              child: const Text('Pay with eSewa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiateEsewaPayment() async {
    final referenceId = "CART-${DateTime.now().millisecondsSinceEpoch}";
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      Esewa(
        context: context,
        productName: 'Cart Checkout - ${cartItems.length} items',
        amount: totalAmount,
        onSuccess: () {
          Navigator.of(context).pop(); // Close loading
          _handleSuccessfulPayment(referenceId);
        },
        onFailure: () {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed. Please try again.')),
          );
        },
        onCancel: () {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled')),
          );
        },
      ).pay();
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    }
  }

  Future<void> _handleSuccessfulPayment(String referenceId) async {
    try {
      // Process order in your backend
      final token = await SecureStorage.getToken();
      final url = Uri.parse('http://10.0.2.2:8000/api/orders');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': cartItems.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
          'payment_reference': referenceId,
          'total_amount': totalAmount,
        }),
      );

      if (response.statusCode == 201) {
        // Clear cart on success
        await _clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.of(context).pop(); // Close the screen
      } else {
        throw Exception('Failed to process order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing order: $e')),
      );
    }
  }

  Future<void> _clearCart() async {
    final token = await SecureStorage.getToken();
    final url = Uri.parse('http://10.0.2.2:8000/api/cart/clear');
    
    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    setState(() {
      cartItems.clear();
      totalAmount = 0.0;
    });
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(child: Text('Your cart is empty!'))
              : Column(
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
                                        item.product.brand ?? 'Maruti',
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
                                : _showPaymentDialog,
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
    );
  }
}