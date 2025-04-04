import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/screens/home_screen.dart';
import 'package:ts_autoparts_app/screens/login_screen.dart';
import 'package:ts_autoparts_app/screens/otp_verification_screen.dart'; // New import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // State variables
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeToTerms = false;
  bool isLoading = false;

  // Focus nodes
  final FocusNode fullNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (passwordController.text != confirmPasswordController.text) {
      _showDialog("Error", "Passwords do not match!");
      return;
    }
    if (!agreeToTerms) {
      _showDialog("Error", "Please agree to terms and conditions");
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
  // Navigate to verification screen with success callback
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
      _showDialog("Registration Error", e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearFields() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
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
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                        icon: Icons.person,
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
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!) 
                              ? 'Enter a valid email' : null,
                        icon: Icons.email,
                        focusNode: emailFocusNode,
                        nextFocusNode: phoneFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Phone Number
                      _buildTextField(
                        controller: phoneController,
                        hintText: "Phone Number",
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter your phone number' :
                            value.length < 10 ? 'Enter a valid phone number' : null,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        focusNode: phoneFocusNode,
                        nextFocusNode: passwordFocusNode,
                      ),
                      const SizedBox(height: 10),

                      // Password
                      _buildPasswordField(
                        controller: passwordController,
                        hintText: "Password",
                        isPasswordVisible: isPasswordVisible,
                        validator: (value) => 
                            value!.isEmpty ? 'Please enter password' :
                            value.length < 8 ? 'Password must be at least 8 characters' : null,
                        focusNode: passwordFocusNode,
                        nextFocusNode: confirmPasswordFocusNode,
                        onVisibilityChanged: () => setState(() => isPasswordVisible = !isPasswordVisible),
                      ),
                      const SizedBox(height: 10),

                      // Confirm Password
                      _buildPasswordField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        isPasswordVisible: isConfirmPasswordVisible,
                        validator: (value) => 
                            value!.isEmpty ? 'Please confirm password' :
                            value != passwordController.text ? 'Passwords do not match' : null,
                        focusNode: confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        onVisibilityChanged: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                      ),
                      const SizedBox(height: 20),

                      // Terms and conditions checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: agreeToTerms,
                            onChanged: (value) => setState(() => agreeToTerms = value!),
                            activeColor: const Color(0xFF144FAB),
                          ),
                          const Text("I agree with "),
                          GestureDetector(
                            onTap: () => _showTermsDialog(),
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
                          onPressed: isLoading ? null : registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF144FAB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
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

                      // Login redirect
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              children: [
                                TextSpan(
                                  text: "Log In",
                                  style: TextStyle(
                                    color: Color(0xFF144FAB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: (_) => nextFocusNode?.requestFocus(),
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