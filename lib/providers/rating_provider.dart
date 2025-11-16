import 'package:flutter/material.dart';
import '../repositories/rating_repository.dart';
import '../models/comment_rating_model.dart';
import '../models/api_response_model.dart';

class RatingProvider with ChangeNotifier {
  Map<int, Rating?> _myRatings = {};
  Map<int, RatingStats> _ratingStats = {};
  Map<int, List<Rating>> _allRatings = {};
  bool _isLoading = false;
  String? _error;

  Map<int, Rating?> get myRatings => _myRatings;
  Map<int, RatingStats> get ratingStats => _ratingStats;
  Map<int, List<Rating>> get allRatings => _allRatings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Rating? getMyRating(int recipeId) {
    return _myRatings[recipeId];
  }

  RatingStats? getRatingStats(int recipeId) {
    return _ratingStats[recipeId];
  }

  List<Rating> getAllRatings(int recipeId) {
    return _allRatings[recipeId] ?? [];
  }

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

  Future<void> loadRatingStats(int recipeId) async {
    try {
      final response = await RatingRepository.getRatingStats(recipeId);
      if (response.success) {
        _ratingStats[recipeId] = response.data!;
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> loadAllRatings(int recipeId) async {
    try {
      final response = await RatingRepository.getRatings(recipeId);
      if (response.success) {
        _allRatings[recipeId] = response.data ?? [];
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<ApiResponse<RatingResponse>> addRating(
    int recipeId,
    int rating,
  ) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await RatingRepository.addRating(recipeId, {
        'rating': rating,
      });
      if (response.success) {
        _myRatings[recipeId] = response.data!.rating;
        _ratingStats[recipeId] = RatingStats(
          averageRating: response.data!.averageRating,
          ratingsCount: response.data!.ratingsCount,
          ratingDistribution: {},
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

  Future<ApiResponse<String>> deleteRating(int recipeId) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await RatingRepository.deleteRating(recipeId);
      if (response.success) {
        _myRatings.remove(recipeId);
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

  Future<void> loadAllRatingData(int recipeId) async {
    await Future.wait([
      loadMyRating(recipeId),
      loadRatingStats(recipeId),
      loadAllRatings(recipeId),
    ]);
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

  void clearRatingDataForRecipe(int recipeId) {
    _myRatings.remove(recipeId);
    _ratingStats.remove(recipeId);
    _allRatings.remove(recipeId);
    notifyListeners();
  }

  void clearAllRatingData() {
    _myRatings.clear();
    _ratingStats.clear();
    _allRatings.clear();
    notifyListeners();
  }
}
