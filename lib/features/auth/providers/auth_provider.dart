import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '/models/user_model.dart';
import '/models/api_response_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _error;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get error => _error;
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      _isLoggedIn = AuthService.isLoggedIn;
      if (_isLoggedIn) {
        _token = AuthService.currentToken;
        final userData = AuthService.currentUser;
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
      }
    } catch (e) {
      _setError('Lỗi khởi tạo xác thực: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse<User>> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await AuthService.login(
        username: username,
        password: password,
      );
      if (response.success) {
        _isLoggedIn = true;
        _currentUser = response.data;
        _token = AuthService.currentToken;
        notifyListeners();
      } else {
        _setError(response.message ?? 'Đăng nhập thất bại');
      }
      return response;
    } catch (e) {
      final error = AuthService.handleNetworkError(e);
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final response = await AuthService.signInWithGoogle();
      if (response.success) {
        _isLoggedIn = true;
        _token = AuthService.currentToken;
        final userData = response.data!['user'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
        notifyListeners();
      } else {
        _setError(response.message ?? 'Đăng nhập Google thất bại');
      }
      return response;
    } catch (e) {
      final error = AuthService.handleNetworkError(e);
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse<String>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await AuthService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        otp: otp,
      );
      if (!response.success) {
        _setError(response.message ?? 'Đăng ký thất bại');
      }
      return response;
    } catch (e) {
      final error = AuthService.handleNetworkError(e);
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse<String>> sendOtp(String email) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await AuthService.sendOtpToEmail(email);
      if (!response.success) {
        _setError(response.message ?? 'Không thể gửi OTP');
      }
      return response;
    } catch (e) {
      final error = AuthService.handleNetworkError(e);
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse<bool>> checkEmailExists(String email) async {
    try {
      return await AuthService.checkEmailExists(email);
    } catch (e) {
      return ApiResponse.error(AuthService.handleNetworkError(e));
    }
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await AuthService.updateProfile(data);
      if (response.success) {
        _currentUser = response.data;
        notifyListeners();
      } else {
        _setError(response.message ?? 'Cập nhật thông tin thất bại');
      }
      return response;
    } catch (e) {
      final error = AuthService.handleNetworkError(e);
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCurrentUser() async {
    if (!_isLoggedIn) return;
    try {
      final response = await AuthService.getCurrentUser();
      if (response.success) {
        _currentUser = response.data;
        notifyListeners();
      }
    } catch (e) {}
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await AuthService.logout();
      _isLoggedIn = false;
      _currentUser = null;
      _token = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Lỗi đăng xuất: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool isValidEmail(String email) {
    return AuthService.isValidEmail(email);
  }

  bool isValidPassword(String password) {
    return AuthService.isValidPassword(password);
  }

  bool isValidName(String name) {
    return AuthService.isValidName(name);
  }

  bool isValidOtp(String otp) {
    return AuthService.isValidOtp(otp);
  }

  Future<void> loadUserProfile() async {
    if (!_isLoggedIn || _token == null) return;
    _setLoadingProfile(true);
    _clearError();
    try {
      final response = await ApiService.getCurrentUser(_token!);
      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
      } else {
        _setError(response.message ?? 'Không thể tải thông tin người dùng');
      }
    } catch (e) {
      _setError('Lỗi tải thông tin: $e');
    } finally {
      _setLoadingProfile(false);
    }
  }

  Future<void> loadUserStats() async {
    if (!_isLoggedIn) return;
    try {
      final mockStats = UserStats(
        recipesCount: 15,
        likesReceived: 120,
        bookmarksReceived: 45,
        commentsCount: 80,
        ratingsGiven: 25,
        averageRating: 4.2,
        followersCount: 150,
        followingCount: 75,
      );
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(stats: mockStats);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingProfile(bool loading) {
    _isLoadingProfile = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
  }
}
