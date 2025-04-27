import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/screens/customer/register_screen.dart';

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
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _isGoogleLoading = false;

  // Login function with validation
  Future<void> _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  // Basic validation
  if (email.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = 'Please enter email and password';
    });
    return;
  }

  // Email format validation
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    setState(() {
      _errorMessage = 'Please enter a valid email address';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final user = await _authService.loginUser(email, password);

    if (user != null) {
      // Save user data and navigate
      await SecureStorage.saveToken(user.accessToken);
      await SecureStorage.saveUsername(user.name);
      await SecureStorage.saveEmail(user.email);
      await SecureStorage.saveRole(user.role);

      final role = await SecureStorage.getRole();
      if (role == 'customer') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (role == 'mechanic') {
        Navigator.pushReplacementNamed(context, '/mechanic');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  } on Exception catch (e) {
    setState(() {
      if (e.toString().contains('user_not_found')) {
        _errorMessage = 'User not found';
      } else if (e.toString().contains('invalid_password')) {
        _errorMessage = 'Invalid password';
      } else {
        _errorMessage = 'Login failed. Please try again.';
      }
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final user = await _authService.loginWithGoogle();
      if (user != null && mounted) {
         Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        _showDialog("Google Sign-In Error", e.toString());
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

   void _showDialog(String title, String message, {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onOkPressed ?? () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF144FAB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 300,
              color: const Color(0xFF144FAB),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  SvgPicture.asset(
                    'assets/images/Logo.svg',
                    height: 110,
                    width: 100,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // Form Section
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

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email",
                      icon: Icons.email,
                      isEmailField: true,
                    ),
                    SizedBox(height: 10),

                    // Password
                    _buildPasswordField(),

                    SizedBox(height: 10),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: Color(0xFF144FAB),
                            ),
                            Text("Remember me"),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Forgot Password clicked")),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xFF144FAB)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Error
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),

                    // Login Button
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
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
                           const SizedBox(height: 20),

                           // OR Divider (unchanged)
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("OR"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Google Sign-In Button (unchanged)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          icon: _isGoogleLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/images/Google.svg',
                                  height: 30,
                                  width: 30,
                                ),
                          label: Text(
                            _isGoogleLoading ? 'Signing In...' : 'Continue with Google',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),


                    SizedBox(height: 295),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(color: Color(0xFF144FAB)),
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

  // Email field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    bool isEmailField = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: isEmailField ? null : Icon(icon, color: Color(0xFF7A879C)),
        suffixIcon: isEmailField ? Icon(icon, color: Color(0xFF7A879C)) : null,
        filled: true,
        fillColor: Color(0xFFF2F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF144FAB), width: 2.0),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  // Password field
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _login(),
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: Colors.grey[600]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Color(0xFF7A879C),
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
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF144FAB), width: 2.0),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
