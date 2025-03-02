import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex; // Index to highlight selected item
  final Function(int) onTap; // Function to handle item tap

  CustomBottomNavbar({
    required this.selectedIndex,
    required this.onTap, // Function to handle tap
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFFF2F7FF), // Set background color
      currentIndex: selectedIndex, // Set the current index here
      onTap: onTap, // Callback function to update the index
      selectedItemColor: Color(0xFF144FAB), // Highlighted color for selected item (label)
      unselectedItemColor: Colors.grey, // Color for unselected items (label)
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Make selected label bold
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Make unselected label bold
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/Home.svg', // Replace with your custom SVG path
            height: 24,
            width: 24,
            color: selectedIndex == 0 ? Color(0xFF144FAB) : Colors.grey, // Change color based on selected index
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/Products.svg', // Replace with your custom SVG path
            height: 24,
            width: 24,
            color: selectedIndex == 1 ? Color(0xFF144FAB) : Colors.grey, // Change color based on selected index
          ),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/Services.svg', // Replace with your custom SVG path
            height: 24,
            width: 24,
            color: selectedIndex == 2 ? Color(0xFF144FAB) : Colors.grey, // Change color based on selected index
          ),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/Cart.svg', // Replace with your custom SVG path
            height: 24,
            width: 24,
            color: selectedIndex == 3 ? Color(0xFF144FAB) : Colors.grey, // Change color based on selected index
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/Profile.svg', // Replace with your custom SVG path
            height: 24,
            width: 24,
            color: selectedIndex == 4 ? Color(0xFF144FAB) : Colors.grey, // Change color based on selected index
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
