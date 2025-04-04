import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ts_autoparts_app/models/user.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Register a new user with email verification support
  Future<User?> registerUser(
    String name,
    String email,
    String phoneNumber,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      print('Registration Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final user = User.fromJson(responseData);
        
        // Store the access token if available
        if (user.accessToken.isNotEmpty) {
          await _storage.write(key: 'access_token', value: user.accessToken);
        }
        
        return user;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Send OTP to the user's email
  Future<bool> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      print('Send OTP Response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Send OTP error: $e');
      return false;
    }
  }

  // Verify OTP for email verification
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Verify OTP Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        // Update user's verification status here if needed
        final responseData = json.decode(response.body);
        if (responseData['verified'] == true) {
          final currentUser = await getAuthenticatedUser();
          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(isEmailVerified: true);
            await _storage.write(
              key: 'user_data',
              value: json.encode(updatedUser.toJson()),
            );
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Verify OTP error: $e');
      return false;
    }
  }

  // Resend verification OTP
  Future<bool> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Resend OTP Response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Resend OTP error: $e');
      return false;
    }
  }

  // Login a user
  Future<User?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final user = User.fromJson(responseData);
        
        // Store the access token
        await _storage.write(key: 'access_token', value: user.accessToken);
        await _storage.write(key: 'user_data', value: json.encode(user.toJson()));
        
        return user;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Fetch authenticated user with verification status
  Future<User?> getAuthenticatedUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final userData = await _storage.read(key: 'user_data');

      if (token != null) {
        // If we have stored user data, return it immediately
        if (userData != null) {
          return User.fromJson(json.decode(userData));
        }

        // Otherwise fetch fresh data from API
        final response = await http.get(
          Uri.parse('$baseUrl/user'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final user = User.fromJson(json.decode(response.body));
          await _storage.write(
            key: 'user_data',
            value: json.encode(user.toJson()),
          );
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<String?> getCurrentToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Logout the user
  Future<bool> logoutUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          await _clearStorage();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Clear all stored data
  Future<void> _clearStorage() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_data');
  }

  // Check if user is logged in and verified
  Future<bool> isUserVerified() async {
    final user = await getAuthenticatedUser();
    return user != null && user.isVerified;
  }
}
