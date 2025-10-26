import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/api_response_model.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';
import '../models/comment_rating_model.dart';

class ApiService {
  static final http.Client _client = http.Client();

  static Map<String, String> _getHeaders({String? token}) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(fromJson(data), statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(ErrorMessages.unknownError, statusCode: response.statusCode);
    }
  }

  static ApiResponse<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = json.decode(response.body);
        final List<T> items = data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
        return ApiResponse.success(items, statusCode: response.statusCode);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(ErrorMessages.unknownError, statusCode: response.statusCode);
    }
  }

  static ApiResponse<String> _handleStringResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(response.body, statusCode: response.statusCode);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(ErrorMessages.unknownError, statusCode: response.statusCode);
    }
  }

  static ApiResponse<bool> _handleBooleanResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return ApiResponse.success(data as bool, statusCode: response.statusCode);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(ErrorMessages.unknownError, statusCode: response.statusCode);
    }
  }

  static Future<ApiResponse<String>> sendOtp(String email) async {
    try {
      // Mock send OTP for testing (uncomment when server has 500 error)
      // await Future.delayed(const Duration(seconds: 1));
      // return ApiResponse.success('OTP sent successfully');
      
      // Real API call - Using query parameters as per backend spec
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtp}')
          .replace(queryParameters: {
        'email': email,
      });
      
      print('🔍 Send OTP Request: email=$email');
      print('🔍 Send OTP URL: $uri');
      
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);

      print('🔍 Send OTP Response: ${response.statusCode} - ${response.body}');
      
      return _handleStringResponse(response);

    } catch (e) {
      print('❌ Send OTP Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String otp,
  }) async {
    try {
      // Mock register for testing (uncomment when server has 500 error)
      // await Future.delayed(const Duration(seconds: 1));
      // return ApiResponse.success('mock_jwt_token_12345');
      
      // Real API call (comment when server has issues)
      final requestBody = {
        'email': email,
        'username': username,
        'password': password,
        'fullName': fullName,
        'otp': otp,
      };
      
      print('🔍 Register Request: ${json.encode(requestBody)}');
      print('🔍 Register URL: ${ApiConfig.baseUrl}${ApiConfig.register}');
      
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.timeout);

      print('🔍 Register Response: ${response.statusCode} - ${response.body}');
      
      return _handleStringResponse(response);

    } catch (e) {
      print('❌ Register Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Mock login for testing (uncomment when server has 500 error)
      // await Future.delayed(const Duration(seconds: 1));
      // return ApiResponse.success('mock_jwt_token_12345');
      
      // Real API call - Using query parameters as per backend spec
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}')
          .replace(queryParameters: {
        'username': username,
        'password': password,
      });
      
      print('🔍 Login Request: username=$username, password=***');
      print('🔍 Login URL: $uri');
      
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);

      print('🔍 Login Response: ${response.statusCode} - ${response.body}');
      
      return _handleStringResponse(response);

    } catch (e) {
      print('❌ Login Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<bool>> checkEmailExists(String email) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userExists}?email=$email'),
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);

      return _handleBooleanResponse(response);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<User>>> getUsers({String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<User>> getUserById(int id, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$id'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<User>> getCurrentUser(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfile}'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<User>> updateUser(int id, Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$id'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> deleteUser(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$id'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleStringResponse(response);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Recipe>>> getRecipes({String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getRecipes}'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Recipe>> getRecipeById(int id, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Recipe>>> getRecipesByUserId(int userId, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/user/$userId'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Recipe>>> getMyRecipes(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myRecipes}'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Recipe>>> searchRecipes(String title, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.searchRecipes}?title=$title'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Recipe>> createRecipe(Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Recipe>> updateRecipe(int id, Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => Recipe.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> deleteRecipe(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleStringResponse(response);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<LikeResponse>> likeRecipe(int id, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/like'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => LikeResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<LikeResponse>> unlikeRecipe(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/like'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => LikeResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<LikeResponse>> toggleLikeRecipe(int id, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/toggle-like'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => LikeResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> isRecipeLiked(int id, String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/is-liked'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<int>>> getLikedRecipeIds(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.likedRecipes}'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => json as int);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<BookmarkResponse>> bookmarkRecipe(int id, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/bookmark'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => BookmarkResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<BookmarkResponse>> unbookmarkRecipe(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/bookmark'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => BookmarkResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<BookmarkResponse>> toggleBookmarkRecipe(int id, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/toggle-bookmark'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => BookmarkResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> isRecipeBookmarked(int id, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/is-bookmarked'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<int>>> getBookmarkedRecipeIds(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookmarkedRecipes}'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => json as int);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Comment>> addComment(int recipeId, Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/comments'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => Comment.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Comment>>> getComments(int recipeId, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/comments'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => Comment.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Comment>> updateComment(int recipeId, int commentId, Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/comments/$commentId'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => Comment.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> deleteComment(int recipeId, int commentId, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/comments/$commentId'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleStringResponse(response);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<RatingResponse>> addRating(int recipeId, Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/ratings'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => RatingResponse.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Rating>> getMyRating(int recipeId, String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/ratings/my-rating'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => Rating.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> deleteRating(int recipeId, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/ratings'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleStringResponse(response);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<RatingStats>> getRatingStats(int recipeId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/ratings/stats'),
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);

      return _handleResponse(response, (json) => RatingStats.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Rating>>> getRatings(int recipeId, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/ratings'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);

      return _handleListResponse(response, (json) => Rating.fromJson(json));
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> googleAuth({
    required String email,
    required String fullName,
    required String googleId,
    String? photoUrl,
  }) async {
    try {
      final username = email.split('@')[0];
      final tempPassword = 'google_${googleId}_${DateTime.now().millisecondsSinceEpoch}';
      final emailExistsResult = await checkEmailExists(email);
      if (!emailExistsResult.success) {
        return ApiResponse.error('Không thể kiểm tra email');
      }

      if (!emailExistsResult.data!) {
        final otpResult = await sendOtp(email);
        if (!otpResult.success) {
          return ApiResponse.error('Không thể gửi OTP');
        }
        final registerResult = await register(
          email: email,
          username: username,
          password: tempPassword,
          fullName: fullName,
          otp: '123456',
        );

        if (!registerResult.success) {
          return ApiResponse.error(registerResult.message ?? 'Lỗi đăng ký');
        }

        final loginResult = await login(
          username: email,
          password: tempPassword,
        );

        if (loginResult.success) {
          return ApiResponse.success({
            'token': loginResult.data,
            'message': 'Đăng ký với Google thành công',
            'isNewUser': true,
          });
        }
      } else {
        final loginResult = await login(
          username: email,
          password: tempPassword,
        );

        if (loginResult.success) {
          return ApiResponse.success({
            'token': loginResult.data,
            'message': 'Đăng nhập với Google thành công',
            'isNewUser': false,
          });
        }
      }

      return ApiResponse.error('Không thể đăng ký/đăng nhập với Google');
    } catch (e) {
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  static void dispose() {
    _client.close();
  }
}