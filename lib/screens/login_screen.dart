import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/screens/register_screen.dart'; // Import Register screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true; // For password visibility toggle
  String? _errorMessage; // To hold error messages

  // Handle login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error messages
    });

    final user = await _authService.loginUser(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null) {
      // Save the token securely
      await SecureStorage.saveToken(user.accessToken);

      // Navigate to home screen or authenticated area
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password'; // Show specific error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF144FAB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Logo
            Container(
              width: double.infinity,
              height: 300,
              color: const Color(0xFF144FAB),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  SvgPicture.asset(
                    'assets/images/Logo.svg', // Path to your SVG file
                    height: 110, // Adjust size as necessary
                    width: 100, // Adjust size as necessary
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // Form Section inside Container with top border radius and expanded space
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back !",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Email Field with icon on the right
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email",
                      icon: Icons.email,
                      textInputAction: TextInputAction.next,
                      isEmailField: true,
                    ),
                    SizedBox(height: 10),

                    // Password Field with Toggle (Only Toggle icon, no lock icon)
                    _buildPasswordField(),

                    SizedBox(height: 20),

                    // Show error message if login failed
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    // Login Button
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: const Color(0xFF144FAB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text('Login'),
                          ),

                    SizedBox(height: 295),

                    // Don't have an account? Register Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? "),
                        TextButton(
                          onPressed: () {
                            // Navigate to the Register screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Register',
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
            ),
          ],
        ),
      ),
    );
  }

  // Reusable text field widget with an option for email field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    bool isEmailField = false, // Added a flag to identify if it's the email field
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: (_) {
        FocusScope.of(context).nextFocus(); // Move to the next field when enter is pressed
      },
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: isEmailField ? null : Icon(icon, color: Color(0xFF7A879C)), // Updated icon color
        suffixIcon: isEmailField ? Icon(icon, color: Color(0xFF7A879C)) : null, // Updated icon color
        filled: true,
        fillColor: Color(0xFFF2F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none, // Remove the stroke
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF144FAB), // Border color when focused
            width: 2.0, // Width of the border when focused
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  // Password field with visibility toggle (Only toggle icon)
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        _login();
      },
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: null, // Remove lock icon
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Color(0xFF7A879C), // Updated icon color
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Color(0xFFF2F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none, // Remove the stroke
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF144FAB), // Border color when focused
            width: 2.0, // Width of the border when focused
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}