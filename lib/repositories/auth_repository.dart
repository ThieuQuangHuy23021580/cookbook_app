import '../core/index.dart';

class AuthRepository {
  static Future<ApiResponse<String>> sendOtp(String email) async {
    return await AuthService.sendOtpToEmail(email);
  }

  static Future<ApiResponse<String>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String otp,
  }) async {
    return await AuthService.register(
      email: email,
      username: username,
      password: password,
      fullName: fullName,
      otp: otp,
    );
  }

  static Future<ApiResponse<User>> login({
    required String username,
    required String password,
  }) async {
    return await AuthService.login(username: username, password: password);
  }

  static Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle() async {
    return await AuthService.signInWithGoogle();
  }

  static Future<void> logout() async {
    await AuthService.logout();
  }

  static Future<ApiResponse<User>> updateProfile(Map<String, dynamic> data) async {
    return await AuthService.updateProfile(data);
  }

  static bool get isLoggedIn => AuthService.isLoggedIn;
  static String? get currentToken => AuthService.currentToken;
  static Map<String, dynamic>? get currentUser => AuthService.currentUser;
  static bool isTokenValid() => AuthService.isTokenValid;
  static bool get isGoogleUser => AuthService.isGoogleUser;

  static bool isValidEmail(String email) {
    return AuthService.isValidEmail(email);
  }

  static bool isValidPassword(String password) {
    return AuthService.isValidPassword(password);
  }

  static bool isValidName(String name) {
    return AuthService.isValidName(name);
  }

  static bool isValidOtp(String otp) {
    return AuthService.isValidOtp(otp);
  }
}
