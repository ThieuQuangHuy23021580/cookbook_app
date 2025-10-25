import 'package:flutter/material.dart';
import '../repositories/rating_repository.dart';
import '../models/comment_rating_model.dart';
import '../models/api_response.dart';

class RatingProvider with ChangeNotifier {
  
  // State variables
  Map<int, Rating?> _myRatings = {}; // recipeId -> my rating
  Map<int, RatingStats> _ratingStats = {}; // recipeId -> stats
  Map<int, List<Rating>> _allRatings = {}; // recipeId -> all ratings
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<int, Rating?> get myRatings => _myRatings;
  Map<int, RatingStats> get ratingStats => _ratingStats;
  Map<int, List<Rating>> get allRatings => _allRatings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get my rating for a specific recipe
  Rating? getMyRating(int recipeId) {
    return _myRatings[recipeId];
  }

  // Get rating stats for a specific recipe
  RatingStats? getRatingStats(int recipeId) {
    return _ratingStats[recipeId];
  }

  // Get all ratings for a specific recipe
  List<Rating> getAllRatings(int recipeId) {
    return _allRatings[recipeId] ?? [];
  }

  // Load my rating for a recipe
  Future<void> loadMyRating(int recipeId) async {
    try {
      final response = await RatingRepository.getMyRating(recipeId);
      if (response.success) {
        _myRatings[recipeId] = response.data;
      } else {
        _myRatings[recipeId] = null;
      }
      notifyListeners();
    } catch (e) {
      _myRatings[recipeId] = null;
    }
  }

  // Load rating stats for a recipe
  Future<void> loadRatingStats(int recipeId) async {
    try {
      final response = await RatingRepository.getRatingStats(recipeId);
      if (response.success) {
        _ratingStats[recipeId] = response.data!;
      }
      notifyListeners();
    } catch (e) {
      // Silent fail for stats
    }
  }

  // Load all ratings for a recipe
  Future<void> loadAllRatings(int recipeId) async {
    try {
      final response = await RatingRepository.getRatings(recipeId);
      if (response.success) {
        _allRatings[recipeId] = response.data ?? [];
      }
      notifyListeners();
    } catch (e) {
      // Silent fail for all ratings
    }
  }

  // Add or update rating
  Future<ApiResponse<RatingResponse>> addRating(int recipeId, int rating) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await RatingRepository.addRating(recipeId, {'rating': rating});
      
      if (response.success) {
        // Update my rating
        _myRatings[recipeId] = response.data!.rating;
        // Update stats
        _ratingStats[recipeId] = RatingStats(
          averageRating: response.data!.averageRating,
          ratingsCount: response.data!.ratingsCount,
          ratingDistribution: {}, // This would need to be provided by the API
        );
        notifyListeners();
      } else {
        _setError(response.message ?? 'Không thể đánh giá');
      }
      
      return response;
    } catch (e) {
      final error = 'Lỗi đánh giá: $e';
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  // Delete rating
  Future<ApiResponse<String>> deleteRating(int recipeId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await RatingRepository.deleteRating(recipeId);
      
      if (response.success) {
        // Remove my rating
        _myRatings.remove(recipeId);
        // Refresh stats
        await loadRatingStats(recipeId);
        notifyListeners();
      } else {
        _setError(response.message ?? 'Không thể xóa đánh giá');
      }
      
      return response;
    } catch (e) {
      final error = 'Lỗi xóa đánh giá: $e';
      _setError(error);
      return ApiResponse.error(error);
    } finally {
      _setLoading(false);
    }
  }

  // Load all data for a recipe
  Future<void> loadAllRatingData(int recipeId) async {
    await Future.wait([
      loadMyRating(recipeId),
      loadRatingStats(recipeId),
      loadAllRatings(recipeId),
    ]);
  }

  // Helper methods
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

  // Clear rating data for a recipe
  void clearRatingDataForRecipe(int recipeId) {
    _myRatings.remove(recipeId);
    _ratingStats.remove(recipeId);
    _allRatings.remove(recipeId);
    notifyListeners();
  }

  // Clear all rating data
  void clearAllRatingData() {
    _myRatings.clear();
    _ratingStats.clear();
    _allRatings.clear();
    notifyListeners();
  }
}
