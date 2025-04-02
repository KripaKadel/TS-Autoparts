import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/screens/login_screen.dart';
import 'package:ts_autoparts_app/screens/home_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String userId;
  final String verificationHash;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.userId,
    required this.verificationHash,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isResendLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkInitialVerification();
  }

  Future<void> _checkInitialVerification() async {
    setState(() => _isLoading = true);
    try {
      final isVerified = await _authService.isUserVerified();
      if (isVerified && mounted) {
        setState(() => _isVerified = true);
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final success = await _authService.verifyEmail(
        widget.userId,
        widget.verificationHash,
      );

      if (success && mounted) {
        setState(() => _isVerified = true);
        _navigateToHome();
      } else if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Verification failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendLoading = true;
      _hasError = false;
    });

    try {
      final success = await _authService.resendVerificationEmail();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to resend verification email.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _isResendLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144FAB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 250,
              color: const Color(0xFF144FAB),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isVerified ? 'Email Verified!' : 'Verify Your Email',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isVerified) ...[
                    const Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Your email has been successfully verified. You can now access all features of the app.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF144FAB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Continue to Home',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'One Last Step',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a verification link to '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF144FAB),
                            ),
                          ),
                          const TextSpan(text: '. Please click the link to verify your account.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Didn't receive the email? Check your spam folder or resend below.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    
                    if (_hasError)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_hasError) const SizedBox(height: 20),
                    
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF144FAB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Verify Email',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Resend Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isResendLoading ? null : _resendVerificationEmail,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF144FAB)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isResendLoading
                            ? const CircularProgressIndicator(color: Color(0xFF144FAB))
                            : const Text(
                                'Resend Verification',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF144FAB),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Login Option
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Already verified? Login here',
                          style: TextStyle(
                            color: Color(0xFF144FAB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}