import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ==================== TOKEN ====================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    print('Token saved successfully: $token');
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'access_token');
    print('Retrieved token: $token');
    return token;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
    print(' Token deleted successfully');
  }

  // ==================== USERNAME ====================
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
    print(' Username saved successfully: $username');
  }

  static Future<String?> getUsername() async {
    final username = await _storage.read(key: 'username');
    print(' Retrieved username: $username');
    return username;
  }

  // ==================== EMAIL ====================
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
    print(' Email saved successfully: $email');
  }

  static Future<String?> getEmail() async {
    final email = await _storage.read(key: 'email');
    print(' Retrieved email: $email');
    return email;
  }

  // ==================== PHONE NUMBER ====================
  static Future<void> savePhoneNumber(String phone) async {
    await _storage.write(key: 'phone_number', value: phone);
    print(' Phone number saved successfully: $phone');
  }

  static Future<String?> getPhoneNumber() async {
    final phone = await _storage.read(key: 'phone_number');
    print('Retrieved phone number: $phone');
    return phone;
  }

  // ==================== PROFILE IMAGE ====================
  static Future<void> saveProfileImage(String imageUrl) async {
    await _storage.write(key: 'profile_image', value: imageUrl);
    print('Profile image saved successfully: $imageUrl');
  }

  static Future<String?> getProfileImage() async {
    final imageUrl = await _storage.read(key: 'profile_image');
    print(' Retrieved profile image URL: $imageUrl');
    return imageUrl;
  }

  // ==================== DELETE EVERYTHING ====================
  static Future<void> deleteUserInfo() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'phone_number');
    await _storage.delete(key: 'profile_image');
    print(' User info deleted successfully');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    print(' All secure storage data cleared');
  }
}
