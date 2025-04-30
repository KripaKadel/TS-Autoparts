// screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onVerificationSuccess;

  const OtpVerificationScreen({
    Key? key,
    required this.email,
    this.onVerificationSuccess,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
  final otp = _otpControllers.map((c) => c.text).join();
  
  // Clear previous messages
  setState(() {
    _errorMessage = null;
    _successMessage = null;
  });

  // Validate OTP length
  if (otp.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please enter a 6-digit OTP'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final verified = await _authService.verifyOtp(widget.email, otp);
    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verified successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      if (widget.onVerificationSuccess != null) {
        widget.onVerificationSuccess!();
      }
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _resendOtp() async {
  setState(() {
    _isResending = true;
    _errorMessage = null;
    _successMessage = null;
  });

  try {
    await _authService.sendOtp(widget.email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New OTP sent to your email'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isResending = false);
  }
}

  

  void _handleOtpInput(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-submit when last digit is entered
    if (index == 5 && value.isNotEmpty) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        foregroundColor: Colors.white,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter OTP',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a 6-digit code to ${widget.email}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _handleOtpInput(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // Error/Success Messages
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_successMessage != null)
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
            
            const SizedBox(height: 20),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
    onPressed: _isLoading ? null : _verifyOtp,
    style: ElevatedButton.styleFrom(
      // Keep default background color (remove if overriding)
      foregroundColor: Colors.white, // Makes text AND loader white
    ),
    child: _isLoading
        ? const CircularProgressIndicator(
            color: Colors.white, // Ensures loader is white
          )
        : const Text(
            'Verify',
            style: TextStyle(
              color: Colors.white, // Explicit white text (redundant but clear)
              fontWeight: FontWeight.bold,
            ),
          ),
  ),
),
            const SizedBox(height: 12),
            
            // Resend OTP
            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resendOtp,
                child: _isResending
                    ? const CircularProgressIndicator()
                    : const Text('Didn\'t receive code? Resend'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}