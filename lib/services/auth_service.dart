import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ts_autoparts_app/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['openid', 'email', 'profile'],
    serverClientId: '30762665291-87vvgm2r0l6ssselbh16u090k0oetu60.apps.googleusercontent.com',
  );

  // Create a reusable HTTP client with SSL verification
  Future<http.Client> get _httpClient async {
    try {
      // Load the certificate from assets
      final sslCert = await rootBundle.load('assets/certs/cacert.pem');
      final securityContext = SecurityContext.defaultContext;
      securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
      
      // Create a custom HttpClient with the security context
      final httpClient = HttpClient(context: securityContext);
      httpClient.badCertificateCallback = (cert, host, port) {
        // Add additional verification logic here if needed
        return false; // Always verify certificates
      };
      
      return IOClient(httpClient);
    } catch (e) {
      debugPrint('Error creating HTTP client: $e');
      // Fallback to regular client if certificate loading fails
      return http.Client();
    }
  }


  // ==================== GOOGLE AUTH METHODS ====================

  Future<User?> loginWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In...');
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        throw Exception('User cancelled Google Sign-In');
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('No ID token received from Google');
      }

      debugPrint('Google authentication successful for ${googleAccount.email}');

      final client = await _httpClient;
      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': googleAuth.idToken,
          'email': googleAccount.email,
          'name': googleAccount.displayName,
          'google_id': googleAccount.id,
          'photo_url': googleAccount.photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = User.fromJson(responseData['user']);
        final token = responseData['token'];
        
        await _saveUserData(user, token);
        return user;
      } else {
        throw Exception('Failed to authenticate with backend: ${response.body}');
      }
    } catch (e) {
      debugPrint('Google login error: $e');
      rethrow;
    }
  }

  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      await _clearStorage();
      debugPrint('Google user signed out successfully');
    } catch (e) {
      debugPrint('Google sign out error: $e');
      rethrow;
    }
  }

  // ==================== AUTH METHODS ====================

   Future<User?> registerUser({
  required String name,
  required String email,
  required String phoneNumber,
  required String password,
  required String confirmPassword,
}) async {
  try {
    final client = await _httpClient;
    final response = await client.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    debugPrint('Registration response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      
      // Your backend returns the user directly without 'user' key or token
      // So we'll create a User object with minimal data
      return User(
        id: responseData['id'] ?? 0,
        name: responseData['name'] ?? name,
        email: responseData['email'] ?? email,
        phoneNumber: responseData['phone_number'] ?? phoneNumber,
        accessToken: '', // Will be obtained after OTP verification
        isEmailVerified: false, // Newly registered users aren't verified yet
      );
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  } catch (e) {
    debugPrint('Registration error: $e');
    rethrow;
  }
}

  Future<bool> sendOtp(String email) async {
    try {
      final response = await _makeHttpPost(
        Uri.parse('$baseUrl/api/send-otp'),
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send OTP error: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _makeHttpPost(
        Uri.parse('$baseUrl/api/verify-otp'),
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['verified'] == true) {
          await _updateUserVerificationStatus();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      final response = await _makeHttpPost(
        Uri.parse('$baseUrl/api/resend-otp'),
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      return false;
    }
  }

   // Login a user
  Future<User?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return User.fromJson(responseBody);
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  Future<User?> getAuthenticatedUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final userData = await _storage.read(key: 'user_data');

      if (token != null && userData != null) {
        return User.fromJson(jsonDecode(userData));
      }

      if (token != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/api/auth/user'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final user = User.fromJson(jsonDecode(response.body));
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(user.toJson()),
          );
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  Future<String?> getCurrentToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<bool> logoutUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/api/logout'),
          headers: await _getAuthHeaders(),
        );
      }
      await _clearStorage();
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }

  Future<bool> isUserVerified() async {
    final user = await getAuthenticatedUser();
    return user?.emailVerifiedAt != null;
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _makeHttpPost(
        Uri.parse('$baseUrl/api/forgot-password'),
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _makeHttpPost(
        Uri.parse('$baseUrl/api/reset-password'),
        body: jsonEncode({
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<void> _saveUserData(User user, String token) async {
    await Future.wait([
      _storage.write(key: 'access_token', value: token),
      _storage.write(key: 'user_data', value: jsonEncode(user.toJson())),
    ]);
  }

  Future<void> _updateUserVerificationStatus() async {
    final currentUser = await getAuthenticatedUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        emailVerifiedAt: DateTime.now(),
      );
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(updatedUser.toJson()),
      );
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _clearStorage() async {
    await Future.wait([
      _storage.delete(key: 'access_token'),
      _storage.delete(key: 'user_data'),
    ]);
  }

  // Method to handle SSL certificates properly for mobile
  Future<http.Response> _makeHttpPost(Uri url, {required String body}) async {
    final client = await _createHttpClient();
    final response = await client.post(url, body: body, headers: {
      'Content-Type': 'application/json',
    });
    return response;
  }

  Future<http.Client> _createHttpClient() async {
    final securityContext = SecurityContext.defaultContext;

    // Load the cacert.pem from assets
    final sslCert = await rootBundle.load('assets/certs/cacert.pem');
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());

    final ioClient = IOClient(HttpClient(context: securityContext));
    return ioClient;
  }

  Future<void> rememberCredentials(String email, String password) async {
  await _storage.write(key: 'remembered_email', value: email);
  await _storage.write(key: 'remembered_password', value: password);
}

Future<void> clearRememberedCredentials() async {
  await _storage.delete(key: 'remembered_email');
  await _storage.delete(key: 'remembered_password');
}

Future<String?> getStoredEmail() async {
  return await _storage.read(key: 'remembered_email');
}

Future<String?> getStoredPassword() async {
  return await _storage.read(key: 'remembered_password');
}
}
