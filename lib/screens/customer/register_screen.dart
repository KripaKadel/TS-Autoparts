import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/screens/customer/home_screen.dart';
import 'package:ts_autoparts_app/screens/customer/login_screen.dart';
import 'package:ts_autoparts_app/screens/customer/otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _emailError;

  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  Future<void> _registerUser() async {
  // Clear any previous email error
  setState(() {
    _emailError = null;
  });
  
  if (!_formKey.currentState!.validate()) return;
  if (_passwordController.text != _confirmPasswordController.text) {
    _showDialog("Error", "Passwords do not match!");
    return;
  }
  if (!_agreeToTerms) {
    _showDialog("Error", "Please agree to terms and conditions");
    return;
  }

  setState(() => _isLoading = true);

  try {
    final user = await _authService.registerUser(
      name: _fullNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: user.email,
            onVerificationSuccess: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      // Parse the specific error format from your backend
      final errorString = e.toString();
      if (errorString.contains('"email":["The email has already been taken."]')) {
        setState(() {
          _emailError = 'The email has already been taken';
        });
        _formKey.currentState!.validate();
      } else {
        // For other errors, show dialog
        _showDialog("Registration Error", errorString);
      }
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
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
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144FAB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo Section
            Container(
              width: double.infinity,
              height: 300,
              color: const Color(0xFF144FAB),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  SvgPicture.asset(
                    'assets/images/Logo.svg',
                    height: 110,
                    width: 100,
                  ),
                ],
              ),
            ),
            
            // Form Section
            Container(
              decoration: const BoxDecoration(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Full Name
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: "Full Name",
                        validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                        icon: Icons.person,
                        focusNode: _fullNameFocusNode,
                        nextFocusNode: _emailFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        hintText: "Email",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email';
                          } else if (_emailError != null) {
                            return _emailError;
                          }
                          return null;
                        },
                        icon: Icons.email,
                        focusNode: _emailFocusNode,
                        nextFocusNode: _phoneFocusNode,
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() {
                              _emailError = null;
                            });
                            _formKey.currentState!.validate();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // Phone Number
                      _buildTextField(
                        controller: _phoneController,
                        hintText: "Phone Number",
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter your phone number' :
                            value.length < 10 ? 'Enter a valid phone number' : null,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        focusNode: _phoneFocusNode,
                        nextFocusNode: _passwordFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Password
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: "Password",
                        isPasswordVisible: _isPasswordVisible,
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter password' :
                            value.length < 8 ? 'Password must be at least 8 characters' : null,
                        focusNode: _passwordFocusNode,
                        nextFocusNode: _confirmPasswordFocusNode,
                        onVisibilityChanged: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      const SizedBox(height: 10),

                      // Confirm Password
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hintText: "Confirm Password",
                        isPasswordVisible: _isConfirmPasswordVisible,
                        validator: (value) => 
                            value!.isEmpty ? 'Please confirm password' :
                            value != _passwordController.text ? 'Passwords do not match' : null,
                        focusNode: _confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        onVisibilityChanged: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      const SizedBox(height: 20),

                      // Terms and conditions checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) => setState(() => _agreeToTerms = value!),
                            activeColor: const Color(0xFF144FAB),
                          ),
                          const Text("I agree with "),
                          GestureDetector(
                            onTap: _showTermsDialog,
                            child: const Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                color: Color(0xFF144FAB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF144FAB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Register",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // OR Divider
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

                      // Google Sign-In Button
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

                      // Login redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have a account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required FormFieldValidator<String> validator,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: (_) => nextFocusNode?.requestFocus(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Icon(icon, color: const Color(0xFF7A879C)),
        filled: true,
        fillColor: const Color(0xFFF2F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF144FAB),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required FormFieldValidator<String> validator,
    required FocusNode focusNode,
    required VoidCallback onVisibilityChanged,
    TextInputAction textInputAction = TextInputAction.next,
    FocusNode? nextFocusNode,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      validator: validator,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: (_) => nextFocusNode?.requestFocus(),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF7A879C),
          ),
          onPressed: onVisibilityChanged,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF144FAB),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "By creating an account, you agree to our:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("1. Privacy Policy"),
              Text("2. Terms of Service"),
              Text("3. Acceptable Use Policy"),
              SizedBox(height: 15),
              Text(
                "Please read our full terms on our website.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}