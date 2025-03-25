import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // for secure storage

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Function to show the logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog

                // Clear the stored token (or session data)
                const storage = FlutterSecureStorage();
                await storage.delete(key: 'access_token'); // Deleting the token

                // Navigate to the login screen and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // Replace with your login route name
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the custom color #144FAB
    final Color customBlue = Color(0xFF144FAB);

    return Scaffold(
      backgroundColor: customBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top blue section with profile info
            Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              color: customBlue,
              child: Row(
                children: [
                  // Profile image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile.jpg'), // Correct path to your image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // User info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'John Dahson',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'johndahson@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // White menu section
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Menu items
                      _buildMenuItem(Icons.edit, 'Edit Profile', customColor: customBlue),
                      _buildMenuItem(Icons.lock, 'Change Password', customColor: customBlue),
                      _buildMenuItem(Icons.email, 'Change Email Address', customColor: customBlue),
                      _buildMenuItem(Icons.settings, 'Settings', customColor: customBlue),
                      _buildMenuItem(Icons.help, 'Help', customColor: customBlue),
                      _buildMenuItem(Icons.info, 'About', customColor: customBlue),
                      _buildMenuItem(Icons.logout, 'Log Out', isLogOut: true, context: context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogOut = false, Color customColor = Colors.blue, BuildContext? context}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogOut ? Colors.red : customColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogOut ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          if (isLogOut) {
            _showLogoutDialog(context!);
          } else {
            // Handle other navigation or actions here
          }
        },
      ),
    );
  }
}
