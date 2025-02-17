import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support
import 'package:ts_autoparts_app/components/navbar.dart'; // Import the custom navbar

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Store the selected index

  // Update selected index on tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex, // Pass the selected index
        onTap: _onItemTapped, // Pass the callback function
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Wrap the entire body with a SingleChildScrollView
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset('assets/images/BLogo.svg', height: 40),
                    CircleAvatar(backgroundImage: AssetImage('assets/profile.jpg')),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search Car Parts or Garage Service',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  height: 152, // Set the height of the container to 152
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align text to left and image to right
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, There 👋', style: TextStyle(color: Colors.black, fontSize: 18)),
                          Text(
                            'Get Up to 50% Off',
                            style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF144FAB),
                            ),
                            onPressed: () {},
                            child: Text('Shop Now', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/discount_image.png', // Replace with your image path
                        height: 152, // Match the height of the rectangle
                        width: 100,  // Set width of the image, you can adjust as needed
                        fit: BoxFit.cover, // Adjust to your preference
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Categories horizontal scroll
                Container(
                  height: 100, // Set the height of the scrollable container
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Fluids', 'Cooling', 'Brakes', 'Shocks', 'Bearings']
                        .map((category) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  Icon(Icons.category, size: 40, color: Colors.blue),
                                  Text(category),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 16),
                Text('Featured Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Featured products horizontal scroll
                Container(
                  height: 250, // Set the height of the scrollable container
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      {'name': 'Air Filter', 'price': 'Rs.250'},
                      {'name': 'Break Pad', 'price': 'Rs.250'},
                    ]
                        .map((product) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.settings, size: 50),
                                    Text(product['name']!, style: TextStyle(fontSize: 16)),
                                    Text(product['price']!,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get 10% off on your first service!',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF144FAB),
                        ),
                        onPressed: () {},
                        child: Text('Book Appointment', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
