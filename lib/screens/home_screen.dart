import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        primaryColor: Color(0xFF144FAB), // Set custom primary color globally
        primarySwatch: MaterialColor(0xFF144FAB, {
          50: Color(0xFFE6F0FF),
          100: Color(0xFFB3D6FF),
          200: Color(0xFF80BBFF),
          300: Color(0xFF4DA0FF),
          400: Color(0xFF1A85FF),
          500: Color(0xFF006AFF), // Your custom color
          600: Color(0xFF0057CC),
          700: Color(0xFF0043B2),
          800: Color(0xFF00308F),
          900: Color(0xFF001D6C),
        }),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
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
                      CircleAvatar(backgroundImage: AssetImage('assets/profile.jpg')),
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
                                      color: Color(0xFF144FAB), // Highlight color
                                      fontWeight: FontWeight.bold, // Make it bold
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
                              onPressed: () {},
                              child: Text('Shop Now', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      // Right side image
                      Container(
                        width: 120, // Adjust width to make it larger
                        height: 180, // Make sure it matches the promotional background height
                        child: Image.asset(
                          'assets/images/filters.png', // The image you want to stick
                          fit: BoxFit.cover, // Ensures it covers the space and removes any gaps
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Categories Section
                Align(
                  alignment: Alignment.centerLeft, // Align text to the left
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
                  alignment: Alignment.centerLeft, // Align text to the left
                  child: Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildProductCard('Air Filter', 'Rs.250', 4.5),
                      _buildProductCard('Break Pad', 'Rs.250', 4.5),
                      _buildProductCard('Brake Shoe', 'Rs.250', 4.5),
                      _buildProductCard('Bearings', 'Rs.250', 4.5),
                      _buildProductCard('Air Filter', 'Rs.250', 4.5),
                      _buildProductCard('Air Filter', 'Rs.250', 4.5),
                    ],
                  ),
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
                              onPressed: () {},
                              child: Text('Book Appointment', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 120,
                        child: SvgPicture.asset(
                          'assets/images/Mechanic.svg', // Replace with SvgPicture for SVG image
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

  // Category Item Builder using SvgPicture.asset
  Widget _buildCategoryItem(String imagePath, String name) {
    return Container(
      width: 80,  // Increased width to make it a bit bigger
      margin: EdgeInsets.only(right: 0.25), // Reduced margin for smaller gap
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,  // Increased height to make the icon bigger
            width: 60,   // Increased width to make the icon bigger
            decoration: BoxDecoration(
              color: Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              imagePath,  // Use SvgPicture to load the SVG
              fit: BoxFit.scaleDown, // Ensures the icon scales to fit inside the container
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 14), // Increased font size for better readability
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Product Card Builder
  Widget _buildProductCard(String name, String price, double rating) {
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
              child: Icon(Icons.filter_alt, size: 50, color: Colors.grey[700]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text('$rating', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Text(price,
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
