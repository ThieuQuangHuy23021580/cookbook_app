import '../core/index.dart';

class RatingRepository {
  static Future<ApiResponse<RatingResponse>> addRating(int recipeId, Map<String, dynamic> data) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.addRating(recipeId, data, token);
  }

  static Future<ApiResponse<Rating>> getMyRating(int recipeId) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.getMyRating(recipeId, token);
  }

  static Future<ApiResponse<String>> deleteRating(int recipeId) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.deleteRating(recipeId, token);
  }

  static Future<ApiResponse<RatingStats>> getRatingStats(int recipeId) async {
    return await ApiService.getRatingStats(recipeId);
  }

  static Future<ApiResponse<List<Rating>>> getRatings(int recipeId) async {
    return await ApiService.getRatings(recipeId, token: AuthService.currentToken);
  }

  static Future<ApiResponse<RatingResponse>> rateRecipe(int recipeId, int rating) async {
    if (rating < 1 || rating > 5) {
      return ApiResponse.error('Đánh giá phải từ 1 đến 5 sao');
    }
    
    return await addRating(recipeId, {'rating': rating});
  }

  static Future<ApiResponse<RatingResponse>> updateRating(int recipeId, int newRating) async {
    return await rateRecipe(recipeId, newRating);
  }

  static Future<bool> hasUserRated(int recipeId) async {
    final result = await getMyRating(recipeId);
    return result.success;
  }

  static Future<Map<String, int>> getRatingDistribution(int recipeId) async {
    final result = await getRatingStats(recipeId);
    if (result.success) {
      return result.data!.ratingDistribution;
    }
    return {};
  }
}
