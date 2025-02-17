import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/screens/home_screen.dart';
import 'package:ts_autoparts_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeToTerms = false;
  bool isLoading = false;

  // Focus nodes to manage focus between text fields
  FocusNode fullNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  void registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showDialog("Error", "Passwords do not match!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await authService.registerUser(
        fullNameController.text,
        emailController.text,
        phoneController.text,
        passwordController.text,
        confirmPasswordController.text,
      );

      if (user != null) {
        _showDialog("Success", "Registration successful! Welcome, ${user.name}!", isSuccess: true);
        _clearFields();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
      backgroundColor: Color(0xFF144FAB),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Full Name
                    _buildTextField(
                      controller: fullNameController,
                      hintText: "Full Name",
                      suffixIcon: Icon(Icons.person, color: Color(0xFF7A879C)), // Updated icon color
                      textInputAction: TextInputAction.next,
                      focusNode: fullNameFocusNode,
                      nextFocusNode: emailFocusNode,
                    ),
                    SizedBox(height: 10),

                    // Email
                    _buildTextField(
                      controller: emailController,
                      hintText: "Email",
                      suffixIcon: Icon(Icons.email, color: Color(0xFF7A879C)), // Updated icon color
                      textInputAction: TextInputAction.next,
                      focusNode: emailFocusNode,
                      nextFocusNode: phoneFocusNode,
                    ),
                    SizedBox(height: 10),

                    // Phone Number
                    _buildTextField(
                      controller: phoneController,
                      hintText: "Phone No",
                      suffixIcon: Icon(Icons.phone, color: Color(0xFF7A879C)), // Updated icon color
                      textInputAction: TextInputAction.next,
                      focusNode: phoneFocusNode,
                      nextFocusNode: passwordFocusNode,
                    ),
                    SizedBox(height: 10),

                    // Password
                    _buildTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: !isPasswordVisible,
                      textInputAction: TextInputAction.next,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF7A879C), // Updated icon color
                        ),
                      ),
                      focusNode: passwordFocusNode,
                      nextFocusNode: confirmPasswordFocusNode,
                    ),
                    SizedBox(height: 10),

                    // Confirm Password
                    _buildTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: !isConfirmPasswordVisible,
                      textInputAction: TextInputAction.done,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
                          });
                        },
                        child: Icon(
                          isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF7A879C), // Updated icon color
                        ),
                      ),
                      focusNode: confirmPasswordFocusNode,
                      nextFocusNode: FocusNode(),
                    ),
                    SizedBox(height: 20),

                    // Terms and conditions checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              agreeToTerms = value!;
                            });
                          },
                        ),
                        Text("I agree with "),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
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
                    SizedBox(height: 10),

                    // Register Button with border radius 6
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: agreeToTerms ? registerUser : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: agreeToTerms
                                  ? const Color(0xFF144FAB)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text("Register"),
                          ),
                    SizedBox(height: 65),

                    // Already have an account? Login Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text(
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
          ],
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(nextFocusNode);
      },
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,  // All icons are now suffix icons with updated color
        filled: true,
        fillColor: Color(0xFFF2F7FF),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF144FAB),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
