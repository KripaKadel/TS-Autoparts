import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/screens/home_screen.dart';
import 'package:ts_autoparts_app/screens/login_screen.dart';
import 'package:ts_autoparts_app/screens/verifyemail_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // [Keep all your existing controllers and variables]
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeToTerms = false;
  bool isLoading = false;

  // Focus nodes
  FocusNode fullNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (passwordController.text != confirmPasswordController.text) {
      _showDialog("Error", "Passwords do not match!");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await authService.registerUser(
        fullNameController.text,
        emailController.text,
        phoneController.text,
        passwordController.text,
        confirmPasswordController.text,
      );

      if (user != null) {
        if (user.isVerified) {
          // If email is already verified (unlikely during registration)
          _showDialog("Success", "Registration successful! Welcome, ${user.name}!", 
            isSuccess: true,
            route: HomeScreen(),
          );
        } else {
          // Navigate to verification screen with proper parameters
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(
                email: user.email,
                userId: user.id.toString(),
                verificationHash: user.verificationHash ?? '',
              ),
            ),
          );
        }
        _clearFields();
      }
    } catch (e) {
      _showDialog("Error", e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // [Keep all your existing helper methods]
  void _clearFields() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void _showDialog(String title, String message, {
    bool isSuccess = false, 
    Widget? route,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess && route != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => route),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
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
                  const SizedBox(height: 10),
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
                        controller: fullNameController,
                        hintText: "Full Name",
                        validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                        suffixIcon: const Icon(Icons.person, color: Color(0xFF7A879C)),
                        textInputAction: TextInputAction.next,
                        focusNode: fullNameFocusNode,
                        nextFocusNode: emailFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Email
                      _buildTextField(
                        controller: emailController,
                        hintText: "Email",
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter your email' :
                            !value.contains('@') ? 'Enter a valid email' : null,
                        suffixIcon: const Icon(Icons.email, color: Color(0xFF7A879C)),
                        textInputAction: TextInputAction.next,
                        focusNode: emailFocusNode,
                        nextFocusNode: phoneFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Phone Number
                      _buildTextField(
                        controller: phoneController,
                        hintText: "Phone No",
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter your phone number' :
                            value.length < 10 ? 'Enter a valid phone number' : null,
                        suffixIcon: const Icon(Icons.phone, color: Color(0xFF7A879C)),
                        textInputAction: TextInputAction.next,
                        focusNode: phoneFocusNode,
                        nextFocusNode: passwordFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Password
                      _buildTextField(
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: !isPasswordVisible,
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter password' :
                            value.length < 8 ? 'Password must be at least 8 characters' : null,
                        textInputAction: TextInputAction.next,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
                          child: Icon(
                            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF7A879C),
                          ),
                        ),
                        focusNode: passwordFocusNode,
                        nextFocusNode: confirmPasswordFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Confirm Password
                      _buildTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: !isConfirmPasswordVisible,
                        validator: (value) => 
                            value!.isEmpty ? 'Please confirm password' :
                            value != passwordController.text ? 'Passwords do not match' : null,
                        textInputAction: TextInputAction.done,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                          child: Icon(
                            isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF7A879C),
                          ),
                        ),
                        focusNode: confirmPasswordFocusNode,
                        nextFocusNode: FocusNode(),
                      ),
                      const SizedBox(height: 20),

                      // Terms and conditions checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: agreeToTerms,
                            onChanged: (value) => setState(() => agreeToTerms = value!),
                          ),
                          const Text("I agree with "),
                          GestureDetector(
                            onTap: () {}, // Add terms screen navigation
                            child: const Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                color: Color(0xFF144FAB),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Register Button
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: agreeToTerms ? registerUser : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: agreeToTerms
                                    ? const Color(0xFF144FAB)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text("Register"),
                            ),
                      const SizedBox(height: 65),

                      // Login redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            ),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Color(0xFF144FAB),
                                fontWeight: FontWeight.bold,
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
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(nextFocusNode),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF2F7FF),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF144FAB),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}