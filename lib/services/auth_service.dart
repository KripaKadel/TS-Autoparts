import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ts_autoparts_app/models/user.dart'; // Import the User model

class AuthService {
  //static const String baseUrl = 'http://192.168.1.64:8000/api';
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  //static const String baseUrl = 'http://192.168.18.153:8000/api';

  // Register a new user (no role field needed)
  Future<User?> registerUser(
    String name,
    String email,
    String phoneNumber,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': confirmPassword, // Corrected to match Laravel's expected field
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');  // Info about the response

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      return User.fromJson(responseBody);
    } else {
      print('Registration failed: ${response.body}');
      return null;
    }
  }

  // Login a user
  Future<User?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
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

  // Fetch authenticated user
  Future<User?> getAuthenticatedUser() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return User.fromJson(responseBody);
      } else {
        print('Failed to fetch user details: ${response.body}');
        return null;
      }
    } else {
      print('No token found');
      return null;
    }
  }

  // Logout the user
  Future<bool> logoutUser() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token != null) {
      // Send the request to logout
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear the token from secure storage
        await storage.delete(key: 'access_token');
        return true;
      } else {
        print('Logout failed: ${response.body}');
        return false;
      }
    } else {
      print('No token found to logout');
      return false;
    }
  }
}