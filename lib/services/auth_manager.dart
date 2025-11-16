import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
class AuthManager {

  static const String _tokenKey = AppConstants.tokenKey;
  static const String _userKey = AppConstants.userDataKey;
  static String? _currentToken;
  static Map<String, dynamic>? _currentUser;
  /// Lấy token hiện tại
  static String? get token => _currentToken;
  /// Lấy thông tin user hiện tại
  static Map<String, dynamic>? get currentUser => _currentUser;
  /// Kiểm tra đã đăng nhập chưa
  static bool get isLoggedIn => _currentToken != null;
  /// Khởi tạo AuthManager (gọi trong main.dart)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentToken = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = jsonDecode(userJson);
      }
    } catch (e) {
      debugPrint('AuthManager initialization error: $e');
      _currentToken = null;
      _currentUser = null;
    }
  }
  /// Lưu token và thông tin user
  static Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentToken = token;
      _currentUser = userData;
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(userData));
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      _currentToken = token;
      _currentUser = userData;
    }
  }
  /// Xóa dữ liệu đăng nhập
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentToken = null;
      _currentUser = null;
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      _currentToken = null;
      _currentUser = null;
    }
  }
  /// Cập nhật thông tin user
  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    _currentUser = userData;
    if (_currentToken != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(userData));
      } catch (e) {
        debugPrint('Error updating user data: $e');
      }
    }
  }
  /// Lấy headers với token cho API calls
  static Map<String, String> getAuthHeaders() {
    if (_currentToken == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_currentToken',
    };
  }
  /// Kiểm tra token có hợp lệ không (có thể thêm logic kiểm tra expiry)
  static bool isTokenValid() {
    if (_currentToken == null) return false;
    return true;
  }
}
