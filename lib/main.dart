import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/components/navbar.dart'; // Import the custom bottom navbar
import 'package:ts_autoparts_app/screens/home_screen.dart'; // Import your Home page
import 'package:ts_autoparts_app/screens/products_screen.dart'; // Import your Products page
import 'package:ts_autoparts_app/screens/services_screen.dart'; // Import your Services page
import 'package:ts_autoparts_app/screens/cart_screen.dart'; // Import your Cart page
import 'package:ts_autoparts_app/screens/profile_screen.dart'; // Import your Profile page

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  // Custom primary color (144FAB)
  final Color primaryColor = Color(0xFF144FAB); // Your desired primary color

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    HomeScreen(),
    ProductsScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  // Function to handle page navigation based on the selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the appropriate page based on the selected index
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor, // Set the primary color for the whole app
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor, // Set AppBar color to primary color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Set the background color for buttons
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor, // Set button color globally
        ),
        scaffoldBackgroundColor: Colors.white, // Set background color
      ),
      home: Scaffold(
        body: _pages[_selectedIndex], // Display the selected page
        bottomNavigationBar: CustomBottomNavbar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            // When an item is tapped, it updates the index and navigates
            _onItemTapped(index);
          },
        ),
      ),
    );
  }
}
