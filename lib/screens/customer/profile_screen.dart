import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/screens/customer/editprofile_screen.dart';
import 'package:ts_autoparts_app/screens/customer/change_password.dart'; // Import the ChangePasswordScreen
import 'package:ts_autoparts_app/screens/customer/my_appointments.dart'; // Import MyAppointmentsScreen
import 'package:ts_autoparts_app/screens/customer/my_orders.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Loading...';
  String _email = '';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final username = await SecureStorage.getUsername() ?? 'Unknown';
    final email = await SecureStorage.getEmail() ?? '';
    final profileImage = await SecureStorage.getProfileImage();

    setState(() {
      _username = username;
      _email = email;
      _profileImagePath = profileImage;
    });

    debugPrint('Retrieved username: $_username');
    debugPrint('Retrieved email: $_email');
    debugPrint('Retrieved image: $_profileImagePath');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await SecureStorage.deleteToken();
                await SecureStorage.deleteUserInfo();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getProfileImage() {
    if (_profileImagePath != null &&
        _profileImagePath!.isNotEmpty &&
        _profileImagePath!.startsWith('http')) {
      final cacheBustedUrl = '$_profileImagePath?v=${DateTime.now().millisecondsSinceEpoch}';
      return NetworkImage(cacheBustedUrl);
    } else {
      return const AssetImage('assets/images/profile.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color customBlue = const Color(0xFF144FAB);

    return Scaffold(
      backgroundColor: customBlue,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              color: customBlue,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        image: _getProfileImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                      _buildMenuItem(Icons.edit, 'Edit Profile', customColor: customBlue, context: context),
                      _buildMenuItem(Icons.lock, 'Change Password', customColor: customBlue, context: context), // Handle Change Password
                      _buildMenuItem(Icons.calendar_today, 'My Appointments', customColor: customBlue, context: context),
                      _buildMenuItem(Icons.shopping_bag, 'My Orders', customColor: customBlue, context: context),
                      _buildMenuItem(Icons.settings, 'Settings', customColor: customBlue, context: context),
                      _buildMenuItem(Icons.help, 'Help', customColor: customBlue, context: context),
                      _buildMenuItem(Icons.info, 'About', customColor: customBlue, context: context),
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

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isLogOut = false,
    Color customColor = Colors.blue,
    BuildContext? context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogOut ? Colors.red : customColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogOut ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () async {
          if (isLogOut) {
            _showLogoutDialog(context!);
          } else {
            if (title == 'Edit Profile') {
              final result = await Navigator.push(
                context!,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
              if (result == true) {
                _loadUserInfo(); // Refresh profile info after editing
              }
            } else if (title == 'Change Password') {  // Navigate to Change Password Screen
              await Navigator.push(
                context!,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            } else if (title == 'My Appointments') {
              await Navigator.push(
                context!,
                MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()),
              );
            } 
            else if (title == 'My Orders') {
  await Navigator.push(
    context!,
    MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
  );
}
          }
        },
      ),
    );
  }
}
