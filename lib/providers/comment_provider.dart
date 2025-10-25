import 'package:flutter/material.dart';
import '../repositories/comment_repository.dart';
import '../models/comment_rating_model.dart';
import '../models/api_response.dart';

class CommentProvider with ChangeNotifier {
  
  // State variables
  Map<int, List<Comment>> _comments = {}; // recipeId -> comments
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<int, List<Comment>> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get comments for a specific recipe
  List<Comment> getCommentsForRecipe(int recipeId) {
    return _comments[recipeId] ?? [];
  }

  // Load comments for a recipe
  Future<void> loadComments(int recipeId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await CommentRepository.getComments(recipeId);
      if (response.success) {
        _comments[recipeId] = response.data ?? [];
      } else {
        _setError(response.message ?? 'Không thể tải bình luận');
      }
    } catch (e) {
      _setError('Lỗi tải bình luận: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add comment
  Future<ApiResponse<Comment>> addComment(int recipeId, String comment, {int? parentCommentId}) async {
    try {
      final response = await CommentRepository.addComment(
        recipeId, 
        {
          'comment': comment,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
        },
      );
      
      if (response.success) {
        // Refresh comments for this recipe
        await loadComments(recipeId);
      }
      
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi thêm bình luận: $e');
    }
  }

  // Update comment
  Future<ApiResponse<Comment>> updateComment(int recipeId, int commentId, String comment) async {
    try {
      final response = await CommentRepository.updateComment(
        recipeId, 
        commentId, 
        {'comment': comment},
      );
      
      if (response.success) {
        // Refresh comments for this recipe
        await loadComments(recipeId);
      }
      
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi cập nhật bình luận: $e');
    }
  }

  // Delete comment
  Future<ApiResponse<String>> deleteComment(int recipeId, int commentId) async {
    try {
      final response = await CommentRepository.deleteComment(
        recipeId, 
        commentId,
      );
      
      if (response.success) {
        // Refresh comments for this recipe
        await loadComments(recipeId);
      }
      
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi xóa bình luận: $e');
    }
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

  // Clear comments for a recipe
  void clearCommentsForRecipe(int recipeId) {
    _comments.remove(recipeId);
    notifyListeners();
  }

  // Clear all comments
  void clearAllComments() {
    _comments.clear();
    notifyListeners();
  }
}
