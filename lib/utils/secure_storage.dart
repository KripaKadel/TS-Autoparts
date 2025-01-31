import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save the token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Get the token securely
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Delete the token
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}
