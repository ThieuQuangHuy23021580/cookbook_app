import 'package:flutter/material.dart';
import '../models/search_history_model.dart';
import '../services/search_history_service.dart';
import '../services/auth_service.dart';

class SearchHistoryProvider with ChangeNotifier {
  List<String> _searchHistory = [];
  SearchHistoryStats? _stats;
  bool _isLoading = false;
  String? _error;
  List<String> get searchHistory => _searchHistory;
  SearchHistoryStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load search history from API
  Future<void> loadSearchHistory({int limit = 10}) async {
    print('📋 [PROVIDER] ========== START LOADING SEARCH HISTORY ==========');
    print('📋 [PROVIDER] Limit: $limit');
    final isLoggedIn = AuthService.isLoggedIn;
    final token = AuthService.currentToken;
    print('🔐 [PROVIDER] User logged in: $isLoggedIn');
    print('🔐 [PROVIDER] Token exists: ${token != null}');
    print('🔐 [PROVIDER] Token length: ${token?.length ?? 0}');
    if (!isLoggedIn || token == null || token.isEmpty) {
      print('❌ [PROVIDER] Cannot load search history - user not authenticated');
      _setError('Vui lòng đăng nhập để xem lịch sử tìm kiếm');
      return;
    }
    _setLoading(true);
    _clearError();
    try {
      print('[PROVIDER] Calling SearchHistoryService...');
      final response = await SearchHistoryService.getSearchHistory(
        limit: limit,
      );
      print('[PROVIDER] Response received');
      print('[PROVIDER] Success: ${response.success}');
      print('[PROVIDER] Data: ${response.data}');
      print('[PROVIDER] Message: ${response.message}');
      if (response.success) {
        _searchHistory = response.data ?? [];
        print('✅ [PROVIDER] Loaded ${_searchHistory.length} search queries');
        print('📋 [PROVIDER] Queries: $_searchHistory');
        print('📋 [PROVIDER] Calling notifyListeners...');
      } else {
        print('❌ [PROVIDER] Failed to load: ${response.message}');
        _setError(response.message ?? 'Không thể tải lịch sử tìm kiếm');
      }
    } catch (e, stackTrace) {
      print('❌ [PROVIDER] Error loading search history: $e');
      print('❌ [PROVIDER] Stack trace: $stackTrace');
      _setError('Lỗi kết nối: $e');
    } finally {
      _setLoading(false);
      print('📋 [PROVIDER] ========== END LOADING SEARCH HISTORY ==========');
    }
  }

  /// Load statistics
  Future<void> loadStats() async {
    try {
      final response = await SearchHistoryService.getStats();
      if (response.success) {
        _stats = response.data;
        print('✅ [PROVIDER] Loaded stats: ${_stats?.totalSearches} searches');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [PROVIDER] Error loading stats: $e');
    }
  }

  /// Delete a specific query
  Future<bool> deleteQuery(String query) async {
    try {
      final response = await SearchHistoryService.deleteQuery(query);
      if (response.success) {
        _searchHistory.remove(query);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Không thể xóa');
        return false;
      }
    } catch (e) {
      print('❌ [PROVIDER] Error deleting query: $e');
      _setError('Lỗi kết nối: $e');
      return false;
    }
  }

  /// Clear all history
  Future<bool> clearAllHistory() async {
    try {
      final response = await SearchHistoryService.clearAllHistory();
      if (response.success) {
        _searchHistory = [];
        _stats = null;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Không thể xóa lịch sử');
        return false;
      }
    } catch (e) {
      print('❌ [PROVIDER] Error clearing history: $e');
      _setError('Lỗi kết nối: $e');
      return false;
    }
  }

  /// Refresh search history after a search
  Future<void> refreshAfterSearch() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await loadSearchHistory();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all data
  void clear() {
    _searchHistory = [];
    _stats = null;
    _error = null;
    notifyListeners();
  }
}
