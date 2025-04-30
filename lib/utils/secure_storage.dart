import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorage {
  // Instance of FlutterSecureStorage
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _profileImageKey = 'profile_image';
  static const String _userIdKey = 'user_id';

  // ==================== TOKEN ====================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    debugPrint('[SecureStorage] Token saved: $token');
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    debugPrint('[SecureStorage] Token retrieved: $token');
    return token;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    debugPrint('[SecureStorage] Token deleted');
  }

  // ==================== USERNAME ====================
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
    debugPrint('[SecureStorage] Username saved: $username');
  }

  static Future<String?> getUsername() async {
    final username = await _storage.read(key: 'username');
    debugPrint('[SecureStorage] Username retrieved: $username');
    return username;
  }

  // ==================== EMAIL ====================
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
    debugPrint('[SecureStorage] Email saved: $email');
  }

  static Future<String?> getEmail() async {
    final email = await _storage.read(key: 'email');
    debugPrint('[SecureStorage] Email retrieved: $email');
    return email;
  }

  static Future<void> savePassword(String password) async {
    await _storage.write(key: 'password', value: password);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: 'password');
  }

  static Future<void> deleteEmail() async {
    await _storage.delete(key: 'email');
  }

  static Future<void> deletePassword() async {
    await _storage.delete(key: 'password');
  }

  // ==================== PHONE NUMBER ====================
  static Future<void> savePhoneNumber(String phone) async {
    await _storage.write(key: 'phone_number', value: phone);
    debugPrint('[SecureStorage] Phone number saved: $phone');
  }

  static Future<String?> getPhoneNumber() async {
    final phone = await _storage.read(key: 'phone_number');
    debugPrint('[SecureStorage] Phone number retrieved: $phone');
    return phone;
  }

  // ==================== PROFILE IMAGE ====================
  static Future<void> saveProfileImage(String imageUrl) async {
    await _storage.write(key: _profileImageKey, value: imageUrl);
    debugPrint('[SecureStorage] Profile image saved: $imageUrl');
  }

  static Future<String?> getProfileImage() async {
    final imageUrl = await _storage.read(key: _profileImageKey);
    debugPrint('[SecureStorage] Profile image URL retrieved: $imageUrl');
    return imageUrl;
  }

  static Future<void> deleteProfileImage() async {
    await _storage.delete(key: _profileImageKey);
    debugPrint('[SecureStorage] Profile image deleted');
  }

  // ==================== ROLE ====================
  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'role', value: role);
    debugPrint('[SecureStorage] Role saved: $role');
  }

  static Future<String?> getRole() async {
    final role = await _storage.read(key: 'role');
    debugPrint('[SecureStorage] Role retrieved: $role');
    return role;
  }

  // ==================== DELETE USER INFO ====================
  static Future<void> deleteUserInfo() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'phone_number');
    await _storage.delete(key: _profileImageKey);
    await _storage.delete(key: 'role');
    debugPrint('[SecureStorage] User info deleted');
  }

  // ==================== CLEAR ALL STORAGE ====================
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    debugPrint('[SecureStorage] All data cleared');
  }

  static Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    return userIdStr != null ? int.parse(userIdStr) : null;
  }

  static Future<void> setUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  static Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }
}
