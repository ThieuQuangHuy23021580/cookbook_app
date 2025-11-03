import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/app_constants.dart';
import '../models/api_response_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'auth_manager.dart';
class AuthService {

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  /// Sign in with Google and authenticate with backend
  static Future<ApiResponse<Map<String, dynamic>>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResponse.error('Đăng nhập bị hủy');
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
        return ApiResponse.success({
          'message': authResult.data!['message'],
          'isNewUser': authResult.data!['isNewUser'],
          'user': {
            'id': googleUser.id,
            'email': googleUser.email,
            'fullName': googleUser.displayName ?? 'Google User',
            'photoUrl': googleUser.photoUrl,
            'isGoogleUser': true,
          },
        });
      } else {
        return ApiResponse.error(authResult.message ?? 'Lỗi đăng nhập với Google');
      }
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return ApiResponse.error('Lỗi đăng nhập: $error');
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
  /// Gửi OTP đến email
  static Future<ApiResponse<String>> sendOtpToEmail(String email) async {
    return await ApiService.sendOtp(email);
  }
  /// Đăng ký tài khoản mới
  static Future<ApiResponse<String>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String otp,
  }) async {
    return await ApiService.register(
      email: email,
      username: username,
      password: password,
      fullName: fullName,
      otp: otp,
    );
  }
  /// Đăng nhập với email/password
  static Future<ApiResponse<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final loginResult = await ApiService.login(
        username: username,
        password: password,
      );
      if (!loginResult.success) {
        print('❌ Login failed: ${loginResult.message}');
        return ApiResponse.error(loginResult.message ?? ErrorMessages.invalidCredentials);
      }
      print('✅ Login successful, token: ${loginResult.data}');
      final userResult = await ApiService.getCurrentUser(loginResult.data!);
      if (!userResult.success) {
        print('❌ GetCurrentUser failed: ${userResult.message}');
        await AuthManager.saveAuthData(
          token: loginResult.data!,
          userData: {'email': username, 'fullName': 'User'},
        );
        return ApiResponse.error(userResult.message ?? 'Không thể lấy thông tin user');
      }
      print('✅ GetCurrentUser successful');
      await AuthManager.saveAuthData(
        token: loginResult.data!,
        userData: userResult.data!.toJson(),
      );
      print('✅ Auth data saved successfully');
      return ApiResponse.success(userResult.data!);
    } catch (e) {
      print('❌ Login exception: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// Đăng xuất
  static Future<void> logout() async {
    await AuthManager.clearAuthData();
  }
  /// Lấy thông tin user hiện tại
  static Future<ApiResponse<User>> getCurrentUser() async {
    final token = AuthManager.token;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.getCurrentUser(token);
  }
  /// Cập nhật thông tin user
  static Future<ApiResponse<User>> updateProfile(Map<String, dynamic> data) async {
    final token = AuthManager.token;
    final currentUser = AuthManager.currentUser;
    if (token == null || currentUser == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }

    final result = await ApiService.updateUser(currentUser['id'], data, token);
    if (result.success) {
      await AuthManager.updateUserData(result.data!.toJson());
    }
    return result;
  }
  /// Kiểm tra email đã tồn tại
  static Future<ApiResponse<bool>> checkEmailExists(String email) async {
    return await ApiService.checkEmailExists(email);
  }
  /// Kiểm tra đã đăng nhập chưa
  static bool get isLoggedIn => AuthManager.isLoggedIn;
  /// Lấy token hiện tại
  static String? get currentToken => AuthManager.token;
  /// Lấy thông tin user hiện tại
  static Map<String, dynamic>? get currentUser => AuthManager.currentUser;
  /// Kiểm tra token có hợp lệ không
  static bool get isTokenValid => AuthManager.isTokenValid();
  /// Kiểm tra có đang đăng nhập Google không
  static bool get isGoogleSignedIn => _googleSignIn.currentUser != null;
  /// Lấy thông tin Google user hiện tại
  static GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;
  /// Kiểm tra có phải Google user không
  static bool get isGoogleUser {
    final user = AuthManager.currentUser;
    return user?['isGoogleUser'] == true;
  }
  /// Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  /// Validate password
  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength &&
           password.length <= AppConstants.maxPasswordLength;
  }
  /// Validate name
  static bool isValidName(String name) {
    return name.length >= AppConstants.minNameLength &&
           name.length <= AppConstants.maxNameLength;
  }
  /// Validate OTP
  static bool isValidOtp(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }
  /// Xử lý lỗi authentication
  static String handleAuthError(ApiResponse response) {
    switch (response.statusCode) {
      case 401:
        return ErrorMessages.invalidCredentials;
      case 400:
        return response.message ?? ErrorMessages.validationError;
      case 409:
        return ErrorMessages.emailExists;
      case 500:
        return ErrorMessages.serverError;
      default:
        return response.message ?? ErrorMessages.unknownError;
    }
  }
  /// Xử lý lỗi network
  static String handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return ErrorMessages.networkError;
    } else if (error.toString().contains('TimeoutException')) {
      return 'Kết nối quá chậm. Vui lòng thử lại.';
    } else {
      return ErrorMessages.unknownError;
    }
  }
}
