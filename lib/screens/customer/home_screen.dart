import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/main.dart';
import 'package:ts_autoparts_app/services/product_service.dart'; // Import the ProductService
import 'package:ts_autoparts_app/models/product.dart'; // Import the Product model
import 'package:ts_autoparts_app/screens/customer/services_screen.dart'; // Assuming ServiceScreen is in service_screen.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TS Autoparts',
      theme: ThemeData(
        primaryColor: Color(0xFF144FAB),
        primarySwatch: MaterialColor(0xFF144FAB, {
          50: Color(0xFFE6F0FF),
          100: Color(0xFFB3D6FF),
          200: Color(0xFF80BBFF),
          300: Color(0xFF4DA0FF),
          400: Color(0xFF1A85FF),
          500: Color(0xFF006AFF),
          600: Color(0xFF0057CC),
          700: Color(0xFF0043B2),
          800: Color(0xFF00308F),
          900: Color(0xFF001D6C),
        }),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => HomeScreen(),
        '/services': (context) => ServicesScreen(), // Navigate to your existing ServiceScreen
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService().fetchProducts(); // Fetch products
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // App Bar with Logo and Profile picture
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      SvgPicture.asset('assets/images/BLogo.svg', height: 40),
                      // Profile Picture
                      CircleAvatar(backgroundImage: AssetImage('assets/images/profile.jpg')),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Car Parts or Garage Service',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Promotional Banner
                Container(
                  height: 180,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hi, There ',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text('👋', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Get Up to ',
                                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '50% Off',
                                    style: TextStyle(color: Color(0xFF144FAB), fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Enhance Your Ride with Incredible\nDiscounts on ',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                  TextSpan(
                                    text: 'Top-Quality Auto Parts!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF144FAB),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF144FAB),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                // Navigate to the existing ServiceScreen page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProductsWrapper()),
                                );
                              },
                              child: Text('Shop Now', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      // Right side image
                      Container(
                        width: 120,
                        height: 180,
                        child: Image.asset(
                          'assets/images/filters.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Categories Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryItem('assets/icons/Fluids.svg', 'Fluids'),
                      _buildCategoryItem('assets/icons/Cooling.svg', 'Cooling'),
                      _buildCategoryItem('assets/icons/Brakes.svg', 'Brakes'),
                      _buildCategoryItem('assets/icons/Shocks.svg', 'Shocks'),
                      _buildCategoryItem('assets/icons/Bearing.svg', 'Bearings'),
                      _buildCategoryItem('assets/icons/Engine.svg', 'Engines'),
                      _buildCategoryItem('assets/icons/Filters.svg', 'Filters'),
                      _buildCategoryItem('assets/icons/BodyParts.svg', 'Body Parts'),
                      _buildCategoryItem('assets/icons/Lights.svg', 'Lights'),
                      _buildCategoryItem('assets/icons/Battery.svg', 'Battery'),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Featured Products Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder<List<Product>>(
                  future: futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No products found'));
                    } else {
                      List<Product> products = snapshot.data!;

                      // Print the image URL for each product
                      for (var product in products) {
                        print("Product image URL: ${product.image_url}");
                      }

                      return Container(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: products.map((product) => _buildProductCard(product)).toList(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),

                // Service Banner Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Get ',
                                    style: TextStyle(color: Colors.black, fontSize: 18),
                                  ),
                                  TextSpan(
                                    text: '10% off',
                                    style: TextStyle(color: Color(0xFF144FAB), fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' on your first service!',
                                    style: TextStyle(color: Colors.black, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF144FAB),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                // Navigate to the existing ServiceScreen page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServicesWrapper()),
                                );
                              },
                              child: Text('Book Appointment', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 120,
                        child: SvgPicture.asset(
                          'assets/images/Mechanic.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Category Item Builder
  Widget _buildCategoryItem(String imagePath, String name) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              imagePath,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Product Card Builder
  Widget _buildProductCard(Product product) {
    final double dummyRating = 4.5;

    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: product.image_url != null
                  ? Image.network(
                      product.image_url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading image: $error");
                        return Icon(Icons.error, size: 50, color: Colors.red);
                      },
                    )
                  : Icon(Icons.image, size: 50, color: Colors.grey[700]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text('$dummyRating', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Rs. ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF144FAB),
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