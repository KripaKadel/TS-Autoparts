import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save the token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    print('Token saved successfully: $token'); // Debug log
  }

  // Get the token securely
  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'access_token');
    print('Retrieved token: $token'); // Debug log
    return token;
  }

  // Delete the token
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
    print('Token deleted successfully'); // Debug log
  }

  // Save the username securely
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
    print('Username saved successfully: $username'); // Debug log
  }

  // Get the username securely
  static Future<String?> getUsername() async {
    final username = await _storage.read(key: 'username');
    print('Retrieved username: $username'); // Debug log
    return username;
  }

  // Save the email securely
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
    print('Email saved successfully: $email'); // Debug log
  }

  // Get the email securely
  static Future<String?> getEmail() async {
    final email = await _storage.read(key: 'email');
    print('Retrieved email: $email'); // Debug log
    return email;
  }

  // Delete the username and email (if needed)
  static Future<void> deleteUserInfo() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'email');
    print('User info deleted successfully'); // Debug log
  }
}
