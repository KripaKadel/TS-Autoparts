import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle

class ResetPasswordWithOtpScreen extends StatefulWidget {
  final String email;
  const ResetPasswordWithOtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordWithOtpScreen> createState() => _ResetPasswordWithOtpScreenState();
}

class _ResetPasswordWithOtpScreenState extends State<ResetPasswordWithOtpScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final authService = AuthService();
      await authService.resetPasswordWithOtp(
        email: widget.email,
        otp: _otpController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
      setState(() {
        _successMessage = 'Password reset successful! You can now log in.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
            children: [
              // Added the message about OTP being sent
              Text(
                'We have sent you OTP in your mail',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8), // Add some spacing
              Text(
                'Enter the OTP sent to your email and your new password.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16), // Add spacing before the form fields
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.length != 6 ? 'Enter 6-digit OTP' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Password too short' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_successMessage!, style: const TextStyle(color: Colors.green)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading 
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}