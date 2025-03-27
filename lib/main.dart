import 'package:flutter/material.dart';
 // Use khalti package
import 'package:ts_autoparts_app/screens/home_screen.dart'; // Import Home page
import 'package:ts_autoparts_app/screens/login_screen.dart'; // Import Login page
import 'package:ts_autoparts_app/screens/profile_screen.dart'; // Import Profile page
import 'package:ts_autoparts_app/screens/register_screen.dart'; // Import Register page
import 'package:ts_autoparts_app/screens/products_screen.dart'; // Import Products page
import 'package:ts_autoparts_app/screens/services_screen.dart'; // Import Services page
import 'package:ts_autoparts_app/screens/cart_screen.dart'; // Import Cart page
import 'package:ts_autoparts_app/components/navbar.dart'; // Import the custom bottom navbar

void main() {
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF144FAB), // Set the primary color for the whole app
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF144FAB), // Set AppBar color to primary color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF144FAB), // Set the background color for buttons
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF144FAB), // Set button color globally
        ),
        scaffoldBackgroundColor: Colors.white, // Set background color
      ),
      // Define routes for navigation
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeWrapper(), // Use a wrapper for HomeScreen
        '/profile': (context) => ProfileWrapper(), // Profile Wrapper
        '/products': (context) => ProductsWrapper(), // Products Wrapper
        '/services': (context) => ServicesWrapper(), // Services Wrapper
        '/cart': (context) => CartWrapper(), // Cart Wrapper
      },
      initialRoute: '/login', // Set the initial route to the LoginScreen
    );
  }
}

// Wrapper for HomeScreen to include the bottom navigation bar
class HomeWrapper extends StatefulWidget {
  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ProductsScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Wrapper for ProductsScreen to include the bottom navigation bar
class ProductsWrapper extends StatefulWidget {
  @override
  _ProductsWrapperState createState() => _ProductsWrapperState();
}

class _ProductsWrapperState extends State<ProductsWrapper> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    HomeScreen(),
    ProductsScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Wrapper for ServicesScreen to include the bottom navigation bar
class ServicesWrapper extends StatefulWidget {
  @override
  _ServicesWrapperState createState() => _ServicesWrapperState();
}

class _ServicesWrapperState extends State<ServicesWrapper> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    HomeScreen(),
    ProductsScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Wrapper for CartScreen to include the bottom navigation bar
class CartWrapper extends StatefulWidget {
  @override
  _CartWrapperState createState() => _CartWrapperState();
}

class _CartWrapperState extends State<CartWrapper> {
  int _selectedIndex = 3;

  final List<Widget> _pages = [
    HomeScreen(),
    ProductsScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Wrapper for ProfileScreen to include the bottom navigation bar
class ProfileWrapper extends StatefulWidget {
  @override
  _ProfileWrapperState createState() => _ProfileWrapperState();
}

class _ProfileWrapperState extends State<ProfileWrapper> {
  int _selectedIndex = 4;

  final List<Widget> _pages = [
    HomeScreen(),
    ProductsScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}