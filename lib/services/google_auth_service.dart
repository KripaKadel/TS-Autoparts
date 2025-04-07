import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['openid', 'email', 'profile'],
    serverClientId: '30762665291-87vvgm2r0l6ssselbh16u090k0oetu60.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      
      if (auth.idToken == null) {
        throw Exception('No ID token received');
      }

      _printDebugInfo(account, auth); // Extracted debug method

      return {
        'id': account.id,
        'email': account.email,
        'name': account.displayName ?? 'Google User',
        'id_token': auth.idToken!,
        'access_token': auth.accessToken,
        'photo_url': account.photoUrl,
      };
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Safe debug printing method
  void _printDebugInfo(GoogleSignInAccount account, GoogleSignInAuthentication auth) {
    if (kDebugMode) { // Only print in debug mode
      debugPrint('''
=== GOOGLE AUTH DEBUG ===
ID Token (truncated): ${auth.idToken?.substring(0, 25)}...
User ID: ${account.id}
Email: ${account.email}
Name: ${account.displayName}
Access Token (truncated): ${auth.accessToken?.substring(0, 25)}...
Photo URL: ${account.photoUrl}
=======================''');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Google Sign-Out Error: $e');
    }
  }
}