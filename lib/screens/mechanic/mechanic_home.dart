import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/models/user.dart';
import 'package:ts_autoparts_app/screens/mechanic/mechanic_appointments_screen.dart';
//import 'package:ts_autoparts_app/screens/mechanic/mechanic_appointments.dart';

class MechanicHomeScreen extends StatefulWidget {
  @override
  _MechanicHomeScreenState createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  late User _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Load the current user from secure storage or get from AuthService
  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService().getAuthenticatedUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('User not found. Please log in again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load user data: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Placeholder for Job List Screen
  Widget _jobListPlaceholder() {
    return Center(child: Text('Job List Screen (Placeholder)'));
  }

  // Placeholder for Customer Requests Screen
  Widget _customerRequestsPlaceholder() {
    return Center(child: Text('Customer Requests Screen (Placeholder)'));
  }

  // Placeholder for Update Profile Screen
  Widget _updateProfilePlaceholder() {
    return Center(child: Text('Update Profile Screen (Placeholder)'));
  }

  // Navigate to job list placeholder
  void _goToJobList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _jobListPlaceholder()),
    );
  }

  // Navigate to customer requests placeholder
  void _goToCustomerRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _customerRequestsPlaceholder()),
    );
  }

  // Navigate to update profile placeholder
  void _goToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _updateProfilePlaceholder()),
    );
  }

  // Navigate to appointments
  void _goToAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MechanicAppointmentsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mechanic Dashboard'),
        backgroundColor: const Color(0xFF144FAB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await AuthService().logoutUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Display mechanic's name and email
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      title: Text('Welcome, ${_currentUser.name}'),
                      subtitle: Text('Role: Mechanic\nEmail: ${_currentUser.email}'),
                    ),
                  ),
                  SizedBox(height: 16),
                  // View Appointments Button
                  ElevatedButton(
                    onPressed: _goToAppointments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144FAB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('View Appointments'),
                  ),
                  SizedBox(height: 16),
                  // View Jobs Button
                  ElevatedButton(
                    onPressed: _goToJobList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144FAB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('View Jobs'),
                  ),
                  SizedBox(height: 16),
                  // View Customer Requests Button
                  ElevatedButton(
                    onPressed: _goToCustomerRequests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144FAB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('View Customer Requests'),
                  ),
                  SizedBox(height: 16),
                  // Update Profile Button
                  ElevatedButton(
                    onPressed: _goToUpdateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144FAB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Update Profile'),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
