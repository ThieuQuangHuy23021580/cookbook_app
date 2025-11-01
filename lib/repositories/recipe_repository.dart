import '../core/index.dart';

class RecipeRepository {
  static Future<ApiResponse<List<Recipe>>> getAllRecipes() async {
    return await ApiService.getRecipes(token: AuthService.currentToken);
  }

  static Future<ApiResponse<Recipe>> getRecipeById(int id) async {
    return await ApiService.getRecipeById(id, token: AuthService.currentToken);
  }

  static Future<ApiResponse<List<Recipe>>> getRecipesByUserId(int userId) async {
    return await ApiService.getRecipesByUserId(userId, token: AuthService.currentToken);
  }

  static Future<ApiResponse<List<Recipe>>> getMyRecipes() async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.getMyRecipes(token);
  }

  static Future<ApiResponse<List<Recipe>>> getRecentlyViewedRecipes({int limit = 20}) async {
    print('👀 [REPOSITORY] getRecentlyViewedRecipes called with limit: $limit');
    final token = AuthService.currentToken;
    if (token == null) {
      print('❌ [REPOSITORY] No token available');
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    final result = await ApiService.getRecentlyViewedRecipes(token, limit: limit);
    print('👀 [REPOSITORY] Got ${result.data?.length ?? 0} recently viewed recipes');
    return result;
  }

  static Future<ApiResponse<List<Recipe>>> searchRecipes(String title) async {
    return await ApiService.searchRecipes(title, token: AuthService.currentToken);
  }

  static Future<ApiResponse<List<Recipe>>> filterByIngredients({
    List<String>? includeIngredients,
    List<String>? excludeIngredients,
  }) async {
    return await ApiService.filterByIngredients(
      includeIngredients: includeIngredients,
      excludeIngredients: excludeIngredients,
      token: AuthService.currentToken,
    );
  }

  static Future<ApiResponse<Recipe>> createRecipe(Map<String, dynamic> data) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.createRecipe(data, token);
  }

  static Future<ApiResponse<Recipe>> updateRecipe(int id, Map<String, dynamic> data) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.updateRecipe(id, data, token);
  }

  static Future<ApiResponse<String>> deleteRecipe(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.deleteRecipe(id, token);
  }

  static Future<ApiResponse<LikeResponse>> likeRecipe(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.likeRecipe(id, token);
  }

  static Future<ApiResponse<LikeResponse>> unlikeRecipe(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.unlikeRecipe(id, token);
  }

  static Future<ApiResponse<LikeResponse>> toggleLikeRecipe(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.toggleLikeRecipe(id, token);
  }

  static Future<ApiResponse<Map<String, dynamic>>> isRecipeLiked(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.isRecipeLiked(id, token);
  }

  static Future<ApiResponse<List<int>>> getLikedRecipeIds() async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.getLikedRecipeIds(token);
  }

  static Future<ApiResponse<BookmarkResponse>> bookmarkRecipe(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.bookmarkRecipe(id, token);
  }

  static Future<ApiResponse<BookmarkResponse>> unbookmarkRecipe(int id) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.unbookmarkRecipe(id, token);
  }

  static Future<ApiResponse<BookmarkResponse>> toggleBookmarkRecipe(int id) async {
    print('🔄 [REPOSITORY] toggleBookmarkRecipe called for Recipe ID: $id');
    final token = AuthService.currentToken;
    if (token == null) {
      print('❌ [REPOSITORY] No token available');
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    print('✅ [REPOSITORY] Token available, calling API service...');
    final result = await ApiService.toggleBookmarkRecipe(id, token);
    print('🔄 [REPOSITORY] API result success: ${result.success}');
    return result;
  }

  static Future<ApiResponse<Map<String, dynamic>>> isRecipeBookmarked(int id) async {
    return await ApiService.isRecipeBookmarked(id, token: AuthService.currentToken);
  }

  static Future<ApiResponse<List<int>>> getBookmarkedRecipeIds() async {
    print('📋 [REPOSITORY] getBookmarkedRecipeIds called');
    final token = AuthService.currentToken;
    if (token == null) {
      print('❌ [REPOSITORY] No token available');
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    final result = await ApiService.getBookmarkedRecipeIds(token);
    print('📋 [REPOSITORY] Got ${result.data?.length ?? 0} bookmarked IDs');
    return result;
  }

  static Future<ApiResponse<List<Recipe>>> getBookmarkedRecipes() async {
    print('📚 [REPOSITORY] getBookmarkedRecipes called');
    final token = AuthService.currentToken;
    if (token == null) {
      print('❌ [REPOSITORY] No token available');
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    
    try {
      // First get the list of bookmarked recipe IDs
      print('📚 [REPOSITORY] Fetching bookmarked recipe IDs...');
      final idsResponse = await ApiService.getBookmarkedRecipeIds(token);
      if (!idsResponse.success) {
        print('❌ [REPOSITORY] Failed to get bookmarked IDs: ${idsResponse.message}');
        return ApiResponse.error(idsResponse.message ?? 'Không thể lấy danh sách ID đã lưu');
      }
      
      final bookmarkedIds = idsResponse.data ?? [];
      print('📚 [REPOSITORY] Got ${bookmarkedIds.length} bookmarked IDs: $bookmarkedIds');
      
      if (bookmarkedIds.isEmpty) {
        print('📚 [REPOSITORY] No bookmarked recipes found');
        return ApiResponse.success([]);
      }
      
      // Then get the full recipe details for each ID
      print('📚 [REPOSITORY] Fetching details for ${bookmarkedIds.length} recipes...');
      List<Recipe> bookmarkedRecipes = [];
      for (int id in bookmarkedIds) {
        print('📚 [REPOSITORY] Fetching recipe ID: $id');
        final recipeResponse = await ApiService.getRecipeById(id, token: token);
        if (recipeResponse.success && recipeResponse.data != null) {
          bookmarkedRecipes.add(recipeResponse.data!);
          print('✅ [REPOSITORY] Added recipe: ${recipeResponse.data!.title}');
        } else {
          print('❌ [REPOSITORY] Failed to get recipe $id: ${recipeResponse.message}');
        }
      }
      
      print('📚 [REPOSITORY] Successfully loaded ${bookmarkedRecipes.length} recipes');
      return ApiResponse.success(bookmarkedRecipes);
    } catch (e) {
      print('❌ [REPOSITORY] Error in getBookmarkedRecipes: $e');
      return ApiResponse.error('Lỗi tải công thức đã lưu: $e');
    }
  }
}
