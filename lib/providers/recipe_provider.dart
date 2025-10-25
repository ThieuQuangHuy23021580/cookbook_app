import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';
import '../models/api_response.dart';

class RecipeProvider with ChangeNotifier {
  
  // State variables
  List<Recipe> _recipes = [];
  List<Recipe> _searchResults = [];
  List<Recipe> _myRecipes = [];
  List<Recipe> _bookmarkedRecipes = [];
  List<int> _likedRecipeIds = [];
  List<int> _bookmarkedRecipeIds = [];
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLoadingMyRecipes = false;
  bool _isLoadingBookmarked = false;
  
  String? _error;
  String? _searchError;
  String? _myRecipesError;
  String? _bookmarkedError;

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get searchResults => _searchResults;
  List<Recipe> get myRecipes => _myRecipes;
  List<Recipe> get bookmarkedRecipes => _bookmarkedRecipes;
  List<int> get likedRecipeIds => _likedRecipeIds;
  List<int> get bookmarkedRecipeIds => _bookmarkedRecipeIds;
  
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoadingMyRecipes => _isLoadingMyRecipes;
  bool get isLoadingBookmarked => _isLoadingBookmarked;
  
  String? get error => _error;
  String? get searchError => _searchError;
  String? get myRecipesError => _myRecipesError;
  String? get bookmarkedError => _bookmarkedError;

  // Load all recipes
  Future<void> loadRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await RecipeRepository.getAllRecipes();
      if (response.success) {
        _recipes = response.data ?? [];
      } else {
        _setError(response.message ?? 'Không thể tải danh sách công thức');
      }
    } catch (e) {
      _setError('Lỗi kết nối: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search recipes
  Future<void> searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      return;
    }
    
    _setSearching(true);
    _clearSearchError();
    
    try {
      final response = await RecipeRepository.searchRecipes(query);
      if (response.success) {
        _searchResults = response.data ?? [];
      } else {
        _setSearchError(response.message ?? 'Không thể tìm kiếm');
      }
    } catch (e) {
      _setSearchError('Lỗi tìm kiếm: $e');
    } finally {
      _setSearching(false);
    }
  }

  // Load my recipes
  Future<void> loadMyRecipes() async {
    _setLoadingMyRecipes(true);
    _clearMyRecipesError();
    
    try {
      final response = await RecipeRepository.getMyRecipes();
      if (response.success) {
        _myRecipes = response.data ?? [];
      } else {
        _setMyRecipesError(response.message ?? 'Không thể tải công thức của tôi');
      }
    } catch (e) {
      _setMyRecipesError('Lỗi tải công thức: $e');
    } finally {
      _setLoadingMyRecipes(false);
    }
  }

  // Load bookmarked recipes
  Future<void> loadBookmarkedRecipes() async {
    _setLoadingBookmarked(true);
    _clearBookmarkedError();
    
    try {
      final response = await RecipeRepository.getBookmarkedRecipes();
      if (response.success) {
        _bookmarkedRecipes = response.data ?? [];
      } else {
        _setBookmarkedError(response.message ?? 'Không thể tải công thức đã lưu');
      }
    } catch (e) {
      _setBookmarkedError('Lỗi tải công thức đã lưu: $e');
    } finally {
      _setLoadingBookmarked(false);
    }
  }

  // Load liked recipe IDs
  Future<void> loadLikedRecipeIds() async {
    try {
      final response = await RecipeRepository.getLikedRecipeIds();
      if (response.success) {
        _likedRecipeIds = response.data ?? [];
      }
    } catch (e) {
      // Silent fail for liked recipes
    }
  }

  // Load bookmarked recipe IDs
  Future<void> loadBookmarkedRecipeIds() async {
    try {
      final response = await RecipeRepository.getBookmarkedRecipeIds();
      if (response.success) {
        _bookmarkedRecipeIds = response.data ?? [];
      }
    } catch (e) {
      // Silent fail for bookmarked recipes
    }
  }

  // Create new recipe
  Future<ApiResponse<Recipe>> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final response = await RecipeRepository.createRecipe(recipeData);
      if (response.success) {
        // Refresh my recipes list
        await loadMyRecipes();
        // Refresh all recipes list
        await loadRecipes();
      }
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi tạo công thức: $e');
    }
  }

  // Update recipe
  Future<ApiResponse<Recipe>> updateRecipe(int id, Map<String, dynamic> recipeData) async {
    try {
      final response = await RecipeRepository.updateRecipe(id, recipeData);
      if (response.success) {
        // Refresh all lists
        await loadRecipes();
        await loadMyRecipes();
        await loadBookmarkedRecipes();
      }
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi cập nhật công thức: $e');
    }
  }

  // Delete recipe
  Future<ApiResponse<String>> deleteRecipe(int id) async {
    try {
      final response = await RecipeRepository.deleteRecipe(id);
      if (response.success) {
        // Refresh all lists
        await loadRecipes();
        await loadMyRecipes();
        await loadBookmarkedRecipes();
      }
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi xóa công thức: $e');
    }
  }

  // Toggle like recipe
  Future<void> toggleLikeRecipe(int recipeId) async {
    try {
      final response = await RecipeRepository.toggleLikeRecipe(recipeId);
      if (response.success) {
        // Update liked recipe IDs
        await loadLikedRecipeIds();
        // Refresh recipes to update like counts
        await loadRecipes();
        await loadSearchResults();
        await loadBookmarkedRecipes();
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  // Toggle bookmark recipe
  Future<void> toggleBookmarkRecipe(int recipeId) async {
    try {
      final response = await RecipeRepository.toggleBookmarkRecipe(recipeId);
      if (response.success) {
        // Update bookmarked recipe IDs
        await loadBookmarkedRecipeIds();
        // Refresh recipes to update bookmark counts
        await loadRecipes();
        await loadSearchResults();
        await loadBookmarkedRecipes();
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  // Refresh search results
  Future<void> loadSearchResults() async {
    // This would be called when we want to refresh search results
    // with updated like/bookmark counts
    if (_searchResults.isNotEmpty) {
      // Reload search results with updated data
      // Implementation depends on how we want to handle this
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setLoadingMyRecipes(bool loading) {
    _isLoadingMyRecipes = loading;
    notifyListeners();
  }

  void _setLoadingBookmarked(bool loading) {
    _isLoadingBookmarked = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setSearchError(String error) {
    _searchError = error;
    notifyListeners();
  }

  void _setMyRecipesError(String error) {
    _myRecipesError = error;
    notifyListeners();
  }

  void _setBookmarkedError(String error) {
    _bookmarkedError = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _clearSearchError() {
    _searchError = null;
  }

  void _clearMyRecipesError() {
    _myRecipesError = null;
  }

  void _clearBookmarkedError() {
    _bookmarkedError = null;
  }

  // Clear all data
  void clearAll() {
    _recipes = [];
    _searchResults = [];
    _myRecipes = [];
    _bookmarkedRecipes = [];
    _likedRecipeIds = [];
    _bookmarkedRecipeIds = [];
    _error = null;
    _searchError = null;
    _myRecipesError = null;
    _bookmarkedError = null;
    notifyListeners();
  }
}
