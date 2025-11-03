import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/search_history_model.dart';
import '../models/api_response_model.dart';
import 'auth_service.dart';
class SearchHistoryService {
  /// Get search history
  static Future<ApiResponse<List<String>>> getSearchHistory({
    int? limit,
    bool showAll = false,
  }) async {
    try {
      final token = AuthService.currentToken;
      print(' [SEARCH HISTORY] Checking token...');
      print(' [SEARCH HISTORY] Token exists: ${token != null}');
      print(' [SEARCH HISTORY] Token length: ${token?.length ?? 0}');
      if (token != null && token.isNotEmpty) {
        print(' [SEARCH HISTORY] Token preview: ${token.substring(0, token.length > 50 ? 50 : token.length)}...');
      }
      if (token == null || token.isEmpty) {
        print(' [SEARCH HISTORY] No token available');
        return ApiResponse.error(ErrorMessages.unauthorized);
      }

      final queryParams = {
        if (limit != null) 'limit': limit.toString(),
        if (showAll) 'showAll': 'true',
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/search-history')
          .replace(queryParameters: queryParams);
      print(' [SEARCH HISTORY] Fetching from: $uri');
      final headers = {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      print(' [SEARCH HISTORY] Request headers: ${headers.keys}');
      print(' [SEARCH HISTORY] Authorization header: Bearer ${token.substring(0, 20)}...');
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(ApiConfig.timeout);
      print(' [SEARCH HISTORY] Response status: ${response.statusCode}');
      print(' [SEARCH HISTORY] Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(' [SEARCH HISTORY] Decoded data type: ${data.runtimeType}');
        print(' [SEARCH HISTORY] Data keys: ${data is Map ? data.keys : 'not a map'}');
        List<String> queries = [];
        if (data is Map<String, dynamic>) {
          print(' [SEARCH HISTORY] Data is Map, checking keys...');
          if (data.containsKey('queries')) {
            print(' [SEARCH HISTORY] Found "queries" key (default response)');
            final queriesData = data['queries'];
            print(' [SEARCH HISTORY] queries data: $queriesData');
            queries = (queriesData as List).map((e) => e.toString()).toList();
          } else if (data.containsKey('history')) {
            print(' [SEARCH HISTORY] Found "history" key (showAll=true response)');
            queries = (data['history'] as List)
                .map((e) => e['searchQuery'] as String)
                .toSet()
                .toList();
          } else {
            print(' [SEARCH HISTORY] No queries or history key found!');
            print(' [SEARCH HISTORY] Available keys: ${data.keys}');
          }
        } else {
          print(' [SEARCH HISTORY] Data is not a Map!');
        }
        print(' [SEARCH HISTORY] Got ${queries.length} queries: $queries');
        return ApiResponse.success(queries);
      } else {
        print(' [SEARCH HISTORY] Error response status: ${response.statusCode}');
        try {
          final data = json.decode(response.body);
          final message = data['message'] ?? data.toString();
          print(' [SEARCH HISTORY] Error message: $message');
          if (message.toString().contains('JDBC') || message.toString().contains('SQL')) {
            return ApiResponse.error('Backend đang gặp sự cố. Vui lòng thử lại sau.');
          }
          return ApiResponse.error(message);
        } catch (e) {
          print(' [SEARCH HISTORY] Could not parse error response: $e');
          final errorMsg = response.body.isNotEmpty
              ? response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)
              : 'Không thể tải lịch sử tìm kiếm';
          if (errorMsg.contains('JDBC') || errorMsg.contains('SQL')) {
            return ApiResponse.error('Backend đang gặp sự cố (SQL Error). Vui lòng báo dev.');
          }
          return ApiResponse.error(errorMsg);
        }
      }
    } catch (e) {
      print(' [SEARCH HISTORY] Error: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }
  /// Save search query manually (usually automatic via search API)
  static Future<ApiResponse<SearchHistory>> saveSearchQuery(String query) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/search-history');
      final response = await http.post(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'searchQuery': query}),
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final searchHistory = SearchHistory.fromJson(data);
        return ApiResponse.success(searchHistory);
      } else if (response.statusCode == 401) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      } else {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Không thể lưu lịch sử';
        return ApiResponse.error(message);
      }
    } catch (e) {
      print(' [SEARCH HISTORY] Save error: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }
  /// Delete all search history
  static Future<ApiResponse<String>> clearAllHistory() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/search-history');
      final response = await http.delete(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return ApiResponse.success('Đã xóa toàn bộ lịch sử tìm kiếm');
      } else if (response.statusCode == 401) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      } else {
        return ApiResponse.error('Không thể xóa lịch sử');
      }
    } catch (e) {
      print(' [SEARCH HISTORY] Clear error: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }
  /// Delete specific query from history
  static Future<ApiResponse<String>> deleteQuery(String query) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/search-history/query')
          .replace(queryParameters: {'query': query});
      final response = await http.delete(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return ApiResponse.success('Đã xóa query: $query');
      } else if (response.statusCode == 401) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      } else {
        return ApiResponse.error('Không thể xóa query');
      }
    } catch (e) {
      print(' [SEARCH HISTORY] Delete query error: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }
  /// Get search history statistics
  static Future<ApiResponse<SearchHistoryStats>> getStats() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/search-history/stats');
      final response = await http.get(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = SearchHistoryStats.fromJson(data);
        return ApiResponse.success(stats);
      } else if (response.statusCode == 401) {
        return ApiResponse.error(ErrorMessages.unauthorized);
      } else {
        return ApiResponse.error('Không thể tải thống kê');
      }
    } catch (e) {
      print(' [SEARCH HISTORY] Stats error: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }
}
