import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/api_response_model.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';
import '../models/comment_rating_model.dart';
import '../models/upload_response_model.dart';
import '../models/notification_model.dart';
import '../models/ai_chat_model.dart';
class ApiService {

  static final http.Client _client = http.Client();
  static Map<String, String> _getHeaders({String? token}) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  /// Get trending search keywords from backend
  /// Supports optional token, days window and limit
  static Future<ApiResponse<List<String>>> getTrendingKeywords({
    String? token,
    int? days,
    int limit = 20,
  }) async {
    try {
      final base = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trendingSearch}');
      final params = <String, String>{
        'limit': limit.toString(),
      };
      if (days != null) params['days'] = days.toString();
      final uri = base.replace(queryParameters: params);
      final headers = _getHeaders(token: token);
      print(' [TRENDING] GET $uri');
      print(' [TRENDING] Headers: ${headers.keys.join(", ")}');
      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);
      print(' [TRENDING] Status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);
        final List<String> keywords = [];
        if (body is List) {
          for (final item in body) {
            if (item is String) {
              keywords.add(item);
            } else if (item is Map<String, dynamic>) {
              final k = item['keyword'] ?? item['key'] ?? item['term'];
              if (k is String) keywords.add(k);
            }
          }
        } else if (body is Map<String, dynamic>) {
          final dynamic trend = body['trending'] ?? body['data'] ?? body['items'];
          if (trend is List) {
            for (final item in trend) {
              if (item is String) {
                keywords.add(item);
              } else if (item is Map<String, dynamic>) {
                final k = item['keyword'] ?? item['key'] ?? item['term'];
                if (k is String) keywords.add(k);
              }
            }
          }
        }
        return ApiResponse.success(keywords);
      } else {
        return ApiResponse.error('Không lấy được từ khóa thịnh hành', statusCode: response.statusCode);
      }
    } catch (e, st) {
      print(' [TRENDING] Error: $e');
      print(' [TRENDING] Stack: $st');
      return ApiResponse.error(ErrorMessages.unknownError);
    }
  }

  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(' [HANDLE RESPONSE] Success status: ${response.statusCode}');
        print(' [HANDLE RESPONSE] Parsing data with fromJson...');
        try {
          final result = fromJson(data);
          print(' [HANDLE RESPONSE] Successfully parsed data');
          return ApiResponse.success(result, statusCode: response.statusCode);
        } catch (parseError, stackTrace) {
          print(' [HANDLE RESPONSE] Parse error: $parseError');
          print(' [HANDLE RESPONSE] Stack trace: $stackTrace');
          print(' [HANDLE RESPONSE] Data received: $data');
          return ApiResponse.error('Lỗi parse dữ liệu: $parseError', statusCode: response.statusCode);
        }
      } else {
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print(' [HANDLE RESPONSE] General error: $e');
      print(' [HANDLE RESPONSE] Stack trace: $stackTrace');
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
        print(' [LIST RESPONSE] Error Status: ${response.statusCode}');
        print(' [LIST RESPONSE] Response Body: ${response.body}');
        final data = json.decode(response.body);
        final errorMessage = data is String ? data : data['message'] ?? ErrorMessages.serverError;
        print(' [LIST RESPONSE] Error Message: $errorMessage');
        return ApiResponse.error(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print(' [LIST RESPONSE] Exception: $e');
      print(' [LIST RESPONSE] Stack trace: $stackTrace');
      print(' [LIST RESPONSE] Response body: ${response.body}');
      return ApiResponse.error(ErrorMessages.unknownError, statusCode: response.statusCode);
    }
  }

  static ApiResponse<List<T>> _handlePrimitiveListResponse<T>(
    http.Response response,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = json.decode(response.body);
        final List<T> items = data.cast<T>().toList();
        return ApiResponse.success(items, statusCode: response.statusCode);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(' [API] Error parsing primitive list: $e');
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
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtp}')
          .replace(queryParameters: {
        'email': email,
      });
      print(' Send OTP Request: email=$email');
      print(' Send OTP URL: $uri');
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);
      print(' Send OTP Response: ${response.statusCode} - ${response.body}');
      return _handleStringResponse(response);
    } catch (e) {
      print(' Send OTP Error: $e');
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
      final requestBody = {
        'email': email,
        'username': username,
        'password': password,
        'fullName': fullName,
        'otp': otp,
      };
      print(' Register Request: ${json.encode(requestBody)}');
      print(' Register URL: ${ApiConfig.baseUrl}${ApiConfig.register}');
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.timeout);
      print(' Register Response: ${response.statusCode} - ${response.body}');
      return _handleStringResponse(response);
    } catch (e) {
      print(' Register Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> login({
    required String username,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}')
          .replace(queryParameters: {
        'username': username,
        'password': password,
      });
      print(' Login Request: username=$username, password=***');
      print(' Login URL: $uri');
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);
      print(' Login Response: ${response.statusCode} - ${response.body}');
      return _handleStringResponse(response);
    } catch (e) {
      print(' Login Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> forgotPassword(String email) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.forgotPassword}';
      print(' [FORGOT PASSWORD] POST $url');
      print(' [FORGOT PASSWORD] Email: $email');
      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: json.encode({'email': email}),
      ).timeout(ApiConfig.timeout);
      print(' [FORGOT PASSWORD] Response Status: ${response.statusCode}');
      print(' [FORGOT PASSWORD] Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(' [FORGOT PASSWORD] Success: OTP sent to email');
        return ApiResponse.success(response.body, statusCode: response.statusCode);
      } else {
        String errorMessage = 'Không thể gửi OTP';
        try {
          final jsonData = json.decode(response.body);
          errorMessage = jsonData['error'] as String? ?? jsonData['message'] as String? ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        print(' [FORGOT PASSWORD] Error: $errorMessage (Status: ${response.statusCode})');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print(' [FORGOT PASSWORD] Exception: $e');
      print(' [FORGOT PASSWORD] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.resetPassword}';
      print(' [RESET PASSWORD] POST $url');
      print(' [RESET PASSWORD] Email: $email');
      final requestBody = {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      };

      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.timeout);
      print(' [RESET PASSWORD] Response Status: ${response.statusCode}');
      print(' [RESET PASSWORD] Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(' [RESET PASSWORD] Success: Password reset successfully');
        return ApiResponse.success(response.body, statusCode: response.statusCode);
      } else {
        String errorMessage = 'Không thể đặt lại mật khẩu';
        try {
          final jsonData = json.decode(response.body);
          errorMessage = jsonData['error'] as String? ?? jsonData['message'] as String? ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        print(' [RESET PASSWORD] Error: $errorMessage (Status: ${response.statusCode})');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print(' [RESET PASSWORD] Exception: $e');
      print(' [RESET PASSWORD] Stack trace: $stackTrace');
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

  static Future<ApiResponse<String>> followUser(int userId, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.followUser(userId)}';
      print(' [FOLLOW USER] POST $url');
      print(' [FOLLOW USER] UserId: $userId');
      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [FOLLOW USER] Response Status: ${response.statusCode}');
      print(' [FOLLOW USER] Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonData = json.decode(response.body);
          final message = jsonData['message'] as String? ?? 'Successfully followed user';
          print(' [FOLLOW USER] Success: $message');
          return ApiResponse.success(message, statusCode: response.statusCode);
        } catch (e) {
          print(' [FOLLOW USER] Success (non-JSON response)');
          return ApiResponse.success(response.body, statusCode: response.statusCode);
        }
      } else {
        String errorMessage = 'Failed to follow user';
        try {
          final jsonData = json.decode(response.body);
          errorMessage = jsonData['error'] as String? ?? jsonData['message'] as String? ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        print(' [FOLLOW USER] Error: $errorMessage (Status: ${response.statusCode})');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print(' [FOLLOW USER] Exception: $e');
      print(' [FOLLOW USER] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<String>> unfollowUser(int userId, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.unfollowUser(userId)}';
      print(' [UNFOLLOW USER] DELETE $url');
      print(' [UNFOLLOW USER] UserId: $userId');
      final response = await _client.delete(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [UNFOLLOW USER] Response Status: ${response.statusCode}');
      print(' [UNFOLLOW USER] Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonData = json.decode(response.body);
          final message = jsonData['message'] as String? ?? 'Successfully unfollowed user';
          print(' [UNFOLLOW USER] Success: $message');
          return ApiResponse.success(message, statusCode: response.statusCode);
        } catch (e) {
          print(' [UNFOLLOW USER] Success (non-JSON response)');
          return ApiResponse.success(response.body, statusCode: response.statusCode);
        }
      } else {
        String errorMessage = 'Failed to unfollow user';
        try {
          final jsonData = json.decode(response.body);
          errorMessage = jsonData['error'] as String? ?? jsonData['message'] as String? ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        print(' [UNFOLLOW USER] Error: $errorMessage (Status: ${response.statusCode})');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print(' [UNFOLLOW USER] Exception: $e');
      print(' [UNFOLLOW USER] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<bool>> checkIsFollowing(int userId, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.checkIsFollowing(userId)}';
      print(' [CHECK FOLLOWING] GET $url');
      print(' [CHECK FOLLOWING] UserId: $userId');
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [CHECK FOLLOWING] Response Status: ${response.statusCode}');
      print(' [CHECK FOLLOWING] Response Body: ${response.body}');
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          final isFollowing = jsonData['isFollowing'] as bool? ?? false;
          print(' [CHECK FOLLOWING] Is Following: $isFollowing');
          return ApiResponse.success(isFollowing, statusCode: response.statusCode);
        } catch (e) {
          print(' [CHECK FOLLOWING] Failed to parse JSON: $e');
          return ApiResponse.error('Failed to parse response');
        }
      } else {
        String errorMessage = 'Failed to check follow status';
        try {
          final jsonData = json.decode(response.body);
          errorMessage = jsonData['error'] as String? ?? jsonData['message'] as String? ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        print(' [CHECK FOLLOWING] Error: $errorMessage (Status: ${response.statusCode})');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print(' [CHECK FOLLOWING] Exception: $e');
      print(' [CHECK FOLLOWING] Stack trace: $stackTrace');
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
      final url = '${ApiConfig.baseUrl}${ApiConfig.users}/$id';
      print(' UpdateUser URL: $url');
      print(' UpdateUser Data: ${json.encode(data)}');
      final response = await _client.put(
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);
      print(' UpdateUser Response: ${response.statusCode} - ${response.body}');
      return _handleResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      print(' UpdateUser Error: $e');
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
      final url = '${ApiConfig.baseUrl}${ApiConfig.recipes}/$id';
      print(' [GET RECIPE BY ID] GET $url (token: ${token != null ? "present" : "none"})');
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [GET RECIPE BY ID] Status: ${response.statusCode}');
      final result = _handleResponse(response, (json) => Recipe.fromJson(json));
      if (result.success) {
        print(' [GET RECIPE BY ID] Successfully loaded recipe: ${result.data?.title}');
        print(' [INFO] Backend should auto-save this to view history');
      } else {
        print(' [GET RECIPE BY ID] Failed: ${result.message}');
      }
      return result;
    } catch (e) {
      print(' [GET RECIPE BY ID] Error: $e');
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

  static Future<ApiResponse<List<Recipe>>> getRecentlyViewedRecipes(String token, {int limit = 20}) async {
    try {
      final url = '${ApiConfig.baseUrl}/recipes/recently-viewed?limit=$limit';
      print(' [RECENTLY VIEWED] GET $url');
      print(' [RECENTLY VIEWED] Token: ${token.substring(0, 20)}...');
      final headers = _getHeaders(token: token);
      print(' [RECENTLY VIEWED] Headers: ${headers.keys.join(", ")}');
      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);
      print(' [RECENTLY VIEWED] Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = _handleListResponse(response, (json) => Recipe.fromJson(json));
        print(' [RECENTLY VIEWED] Found ${result.data?.length ?? 0} recipes');
        return result;
      } else {
        return _handleListResponse(response, (json) => Recipe.fromJson(json));
      }
    } catch (e, stackTrace) {
      print(' [RECENTLY VIEWED] Error: $e');
      print(' [RECENTLY VIEWED] Stack trace: $stackTrace');
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
  /// POST /api/recipes/filter-by-ingredients - Filter recipes by ingredients (Public - no auth required)
  static Future<ApiResponse<List<Recipe>>> filterByIngredients({
    List<String>? includeIngredients,
    List<String>? excludeIngredients,
    String? token,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.filterByIngredients}';
      print(' [FILTER INGREDIENTS API] POST $url');
      print(' [FILTER INGREDIENTS API] Include: ${includeIngredients ?? []}');
      print(' [FILTER INGREDIENTS API] Exclude: ${excludeIngredients ?? []}');
      final requestBody = <String, dynamic>{};
      if (includeIngredients != null && includeIngredients.isNotEmpty) {
        requestBody['includeIngredients'] = includeIngredients;
      }
      if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
        requestBody['excludeIngredients'] = excludeIngredients;
      }

      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.timeout);
      print(' [FILTER INGREDIENTS API] Status: ${response.statusCode}');
      print(' [FILTER INGREDIENTS API] Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
      return _handleListResponse(response, (json) => Recipe.fromJson(json));
    } catch (e, stackTrace) {
      print(' [FILTER INGREDIENTS API] Exception: $e');
      print(' [FILTER INGREDIENTS API] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Recipe>> createRecipe(Map<String, dynamic> data, String token) async {
    try {
      print(' [CREATE RECIPE API] Request: POST ${ApiConfig.baseUrl}${ApiConfig.recipes}');
      print(' [CREATE RECIPE API] Request Data:');
      print('   - Title: ${data['title']}');
      print('   - Image URL: ${data['imageUrl']}');
      print('   - Ingredients: ${data['ingredients']?.length ?? 0}');
      print('   - Steps: ${data['steps']?.length ?? 0}');
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.recipes}'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);
      print(' [CREATE RECIPE API] Response Status: ${response.statusCode}');
      print(' [CREATE RECIPE API] Response Body: ${response.body}');
      return _handleResponse(response, (json) => Recipe.fromJson(json));
    } catch (e, stackTrace) {
      print(' [CREATE RECIPE API] Error: $e');
      print(' [CREATE RECIPE API] Stack trace: $stackTrace');
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
      return _handlePrimitiveListResponse<int>(response);
    } catch (e) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<BookmarkResponse>> bookmarkRecipe(int id, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/bookmark';
      print(' [BOOKMARK API] Request: POST $url');
      print(' [BOOKMARK API] Recipe ID: $id');
      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [BOOKMARK API] Response Status: ${response.statusCode}');
      print(' [BOOKMARK API] Response Body: ${response.body}');
      return _handleResponse(response, (json) => BookmarkResponse.fromJson(json));
    } catch (e) {
      print(' [BOOKMARK API] Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<BookmarkResponse>> unbookmarkRecipe(int id, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/bookmark';
      print(' [UNBOOKMARK API] Request: DELETE $url');
      print(' [UNBOOKMARK API] Recipe ID: $id');
      final response = await _client.delete(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [UNBOOKMARK API] Response Status: ${response.statusCode}');
      print(' [UNBOOKMARK API] Response Body: ${response.body}');
      return _handleResponse(response, (json) => BookmarkResponse.fromJson(json));
    } catch (e) {
      print(' [UNBOOKMARK API] Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<BookmarkResponse>> toggleBookmarkRecipe(int id, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.recipes}/$id/toggle-bookmark';
      print(' [TOGGLE BOOKMARK API] Request: POST $url');
      print(' [TOGGLE BOOKMARK API] Recipe ID: $id');
      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [TOGGLE BOOKMARK API] Response Status: ${response.statusCode}');
      print(' [TOGGLE BOOKMARK API] Response Body: ${response.body}');
      return _handleResponse(response, (json) => BookmarkResponse.fromJson(json));
    } catch (e) {
      print(' [TOGGLE BOOKMARK API] Error: $e');
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
      final url = '${ApiConfig.baseUrl}${ApiConfig.bookmarkedRecipes}';
      print(' [GET BOOKMARKED IDS API] Request: GET $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [GET BOOKMARKED IDS API] Response Status: ${response.statusCode}');
      print(' [GET BOOKMARKED IDS API] Response Body: ${response.body}');
      final result = _handlePrimitiveListResponse<int>(response);
      print(' [GET BOOKMARKED IDS API] Parsed ${result.data?.length ?? 0} IDs: ${result.data}');
      return result;
    } catch (e) {
      print(' [GET BOOKMARKED IDS API] Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<Comment>> addComment(int recipeId, Map<String, dynamic> data, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/comments';
      print(' AddComment URL: $url');
      print(' AddComment Data: ${json.encode(data)}');
      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);
      print(' AddComment Response: ${response.statusCode} - ${response.body}');
      return _handleResponse(response, (json) => Comment.fromJson(json));
    } catch (e) {
      print(' AddComment Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static Future<ApiResponse<List<Comment>>> getComments(int recipeId, {String? token}) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.recipes}/$recipeId/comments';
      print(' GetComments URL: $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' GetComments Response: ${response.statusCode} - ${response.body}');
      return _handleListResponse(response, (json) => Comment.fromJson(json));
    } catch (e) {
      print(' GetComments Error: $e');
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

  static Future<ApiResponse<UploadResponse>> uploadImage({
    required File imageFile,
    String type = 'avatars',
    String? token,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.uploadImage}';
      print(' [UPLOAD API] Request: POST $url');
      print(' [UPLOAD API] File: ${imageFile.path}');
      print(' [UPLOAD API] Type: $type');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final file = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(file);
      request.fields['type'] = type;
      print(' [UPLOAD API] Sending request...');
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      print(' [UPLOAD API] Response Status: ${response.statusCode}');
      print(' [UPLOAD API] Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final uploadResponse = UploadResponse.fromJson(data);
        return ApiResponse.success(uploadResponse, statusCode: response.statusCode);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data is String ? data : data['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(' [UPLOAD API] Error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// GET /api/notifications - Get all notifications
  static Future<ApiResponse<List<AppNotification>>> getNotifications(String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.notifications}';
      print(' [NOTIFICATION API] GET $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [NOTIFICATION API] Status: ${response.statusCode}');
      print(' [NOTIFICATION API] Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(' [NOTIFICATION API] Found ${data.length} notifications');
        final notifications = data.map((json) => AppNotification.fromJson(json)).toList();
        return ApiResponse.success(notifications);
      } else {
        final errorData = json.decode(response.body);
        print(' [NOTIFICATION API] Error: ${errorData['message']}');
        return ApiResponse.error(
          errorData['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print(' [NOTIFICATION API] Get notifications error: $e');
      print(' [NOTIFICATION API] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// GET /api/notifications/unread - Get unread notifications
  static Future<ApiResponse<List<AppNotification>>> getUnreadNotifications(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notifications}/unread'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final notifications = data.map((json) => AppNotification.fromJson(json)).toList();
        return ApiResponse.success(notifications);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(' [NOTIFICATION API] Get unread notifications error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// GET /api/notifications/unread/count - Get unread count
  static Future<ApiResponse<int>> getUnreadNotificationCount(String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.notifications}/unread/count';
      print(' [NOTIFICATION COUNT] GET $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [NOTIFICATION COUNT] Status: ${response.statusCode}');
      print(' [NOTIFICATION COUNT] Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final count = data['count'] as int;
        print(' [NOTIFICATION COUNT] Unread count: $count');
        return ApiResponse.success(count);
      } else {
        print(' [NOTIFICATION COUNT] Error status: ${response.statusCode}');
        return ApiResponse.error(ErrorMessages.serverError, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print(' [NOTIFICATION COUNT] Get unread count error: $e');
      print(' [NOTIFICATION COUNT] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// PUT /api/notifications/:id/read - Mark notification as read
  static Future<ApiResponse<String>> markNotificationAsRead(int notificationId, String token) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.notifications}/$notificationId/read';
      print(' [NOTIFICATION READ] PUT $url');
      final response = await _client.put(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      print(' [NOTIFICATION READ] Status: ${response.statusCode}');
      print(' [NOTIFICATION READ] Body: ${response.body}');
      if (response.statusCode == 200) {
        print(' [NOTIFICATION READ] Marked notification $notificationId as read');
        return ApiResponse.success('Đã đánh dấu đã đọc');
      } else {
        final errorData = json.decode(response.body);
        print(' [NOTIFICATION READ] Error: ${errorData['message']}');
        return ApiResponse.error(
          errorData['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print(' [NOTIFICATION READ] Mark as read error: $e');
      print(' [NOTIFICATION READ] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// DELETE /api/notifications/:id - Delete notification
  static Future<ApiResponse<String>> deleteNotification(int notificationId, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notifications}/$notificationId'),
        headers: _getHeaders(token: token),
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return ApiResponse.success('Đã xóa thông báo');
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['message'] ?? ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(' [NOTIFICATION API] Delete notification error: $e');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }
  /// POST /api/ai/chat - Chat with AI about recipes (Public - no auth required)
  static Future<ApiResponse<AIChatResponse>> chatWithAI({
    required String question,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.aiChat}';
      print(' [AI CHAT API] POST $url');
      print(' [AI CHAT API] Question: $question');
      final requestBody = {
        'question': question,
      };

      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.timeout);
      print(' [AI CHAT API] Status: ${response.statusCode}');
      print(' [AI CHAT API] Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final aiResponse = AIChatResponse.fromJson(data as Map<String, dynamic>);
        print(' [AI CHAT API] Success - Answer length: ${aiResponse.answer.length}, Sources: ${aiResponse.sources.length}');
        return ApiResponse.success(aiResponse);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData is Map<String, dynamic>
            ? (errorData['error'] ?? errorData['message'] ?? ErrorMessages.serverError)
            : (errorData.toString().isNotEmpty ? errorData.toString() : ErrorMessages.serverError);
        print(' [AI CHAT API] Error: $errorMessage');
        return ApiResponse.error(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print(' [AI CHAT API] Exception: $e');
      print(' [AI CHAT API] Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.networkError);
    }
  }

  static void dispose() {
    _client.close();
  }
}
