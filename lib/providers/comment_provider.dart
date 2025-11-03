import 'package:flutter/material.dart';
import '../repositories/comment_repository.dart';
import '../models/comment_rating_model.dart';
import '../models/api_response_model.dart';

class CommentProvider with ChangeNotifier {
  Map<int, List<Comment>> _comments = {};
  bool _isLoading = false;
  String? _error;

  Map<int, List<Comment>> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Comment> getCommentsForRecipe(int recipeId) {
    return _comments[recipeId] ?? [];
  }

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

  Future<ApiResponse<Comment>> addComment(
    int recipeId,
    String comment, {
    int? parentCommentId,
    int? repliedToUserId,
    String? repliedToUserName,
  }) async {
    try {
      print('CommentProvider.addComment - Starting for recipeId: $recipeId');
      final response = await CommentRepository.addComment(recipeId, {
        'comment': comment,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
        if (repliedToUserId != null) 'repliedToUserId': repliedToUserId,
        if (repliedToUserName != null) 'repliedToUserName': repliedToUserName,
      });
      print(
        'CommentProvider.addComment - Response success: ${response.success}',
      );
      print('CommentProvider.addComment - Response data: ${response.data}');
      if (response.success) {
        if (response.data != null) {
          print('CommentProvider.addComment - Adding comment to local state');
          if (!_comments.containsKey(recipeId)) {
            _comments[recipeId] = [];
          }
          _comments[recipeId]!.insert(0, response.data!);
          print(
            'CommentProvider.addComment - Current comments count: ${_comments[recipeId]?.length}',
          );
          notifyListeners();
          print('CommentProvider.addComment - notifyListeners() called');
        }
        print('CommentProvider.addComment - Refreshing from server');
        await loadComments(recipeId);
        print('CommentProvider.addComment - Refresh complete');
      }
      return response;
    } catch (e) {
      print('CommentProvider.addComment - Error: $e');
      return ApiResponse.error('Lỗi thêm bình luận: $e');
    }
  }

  Future<ApiResponse<Comment>> updateComment(
    int recipeId,
    int commentId,
    String comment,
  ) async {
    try {
      final response = await CommentRepository.updateComment(
        recipeId,
        commentId,
        {'comment': comment},
      );
      if (response.success) {
        await loadComments(recipeId);
      }
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi cập nhật bình luận: $e');
    }
  }

  Future<ApiResponse<String>> deleteComment(int recipeId, int commentId) async {
    try {
      final response = await CommentRepository.deleteComment(
        recipeId,
        commentId,
      );
      if (response.success) {
        await loadComments(recipeId);
      }
      return response;
    } catch (e) {
      return ApiResponse.error('Lỗi xóa bình luận: $e');
    }
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

  void clearCommentsForRecipe(int recipeId) {
    _comments.remove(recipeId);
    notifyListeners();
  }

  void clearAllComments() {
    _comments.clear();
    notifyListeners();
  }
}
