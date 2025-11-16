import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_manager.dart';
class GoogleAuthService {

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  static GoogleSignIn get googleSignIn => _googleSignIn;
  /// Sign in with Google and authenticate with backend
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Đăng nhập bị hủy'};
      }

      final authResult = await ApiService.googleAuth(
        email: googleUser.email,
        fullName: googleUser.displayName ?? 'Google User',
        googleId: googleUser.id,
        photoUrl: googleUser.photoUrl,
      );
      if (authResult.success) {
        await AuthManager.saveAuthData(
          token: authResult.data!['token'],
          userData: {
            'id': googleUser.id,
            'email': googleUser.email,
            'fullName': googleUser.displayName ?? 'Google User',
            'photoUrl': googleUser.photoUrl,
            'isGoogleUser': true,
          },
        );
        return {
          'success': true,
          'message': authResult.data!['message'],
          'user': {
            'id': googleUser.id,
            'email': googleUser.email,
            'fullName': googleUser.displayName ?? 'Google User',
            'photoUrl': googleUser.photoUrl,
            'isGoogleUser': true,
          },
        };
      } else {
        return {
          'success': false,
          'message': authResult.message ?? 'Lỗi đăng nhập với Google',
        };
      }
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return {'success': false, 'message': 'Lỗi đăng nhập: $error'};
    }
  }
  /// Sign out from Google and clear auth data
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await AuthManager.clearAuthData();
    } catch (error) {
      debugPrint('Google Sign-Out Error: $error');
    }
  }
  /// Check if user is currently signed in
  static bool isSignedIn() {
    return AuthManager.isLoggedIn;
  }
  /// Get current user from AuthManager
  static Map<String, dynamic>? getCurrentUser() {
    return AuthManager.currentUser;
  }
  /// Get user authentication details
  static Map<String, dynamic>? getUserDetails() {
    return AuthManager.currentUser;
  }
}
