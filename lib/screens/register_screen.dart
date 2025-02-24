import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/services/auth_service.dart'; // Import the AuthService
import 'package:ts_autoparts_app/screens/home_screen.dart'; // Import the Homepage screen
import 'package:ts_autoparts_app/screens/login_screen.dart'; // Import the Login screen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showDialog("Error", "Passwords do not match!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Register user with 'customer' role automatically (role is not passed as parameter)
      final user = await authService.registerUser(
        fullNameController.text,
        emailController.text,
        phoneController.text,
        passwordController.text,
        confirmPasswordController.text, // Pass confirm password here
      );

      if (user != null) {
        _showDialog("Success", "Registration successful! Welcome, ${user.name}!", isSuccess: true);
        _clearFields();

        // Navigate to the Home screen after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your HomeScreen widget
        );
      } else {
        _showDialog("Error", "Registration failed. Please try again.");
      }
    } catch (e) {
      _showDialog("Error", "An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearFields() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                // Close the dialog and go to the Home screen when registration is successful
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFF144FAB),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_filled,
                    color: Colors.white,
                    size: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "TS AUTOPARTS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "SINCE 2012",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                children: [
                  // Full Name
                  _buildTextField(
                    controller: fullNameController,
                    hintText: "Full Name",
                    icon: Icons.person,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 10),

                  // Email
                  _buildTextField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 10),

                  // Phone Number
                  _buildTextField(
                    controller: phoneController,
                    hintText: "Phone No",
                    icon: Icons.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 10),

                  // Password
                  _buildTextField(
                    controller: passwordController,
                    hintText: "Password",
                    icon: Icons.visibility,
                    obscureText: !isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      child: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Confirm Password
                  _buildTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    icon: Icons.visibility,
                    obscureText: !isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                      child: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Register Button
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: registerUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: const Color(0xFF144FAB),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Register"),
                        ),

                  SizedBox(height: 20),

                  // Already have an account? Login Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      TextButton(
                        onPressed: () {
                          // Navigate to the Login screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF144FAB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: (_) {
        FocusScope.of(context).nextFocus(); // Move to the next field when enter is pressed
      },
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: null, // Icons on the right side, so set the left one to null
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
