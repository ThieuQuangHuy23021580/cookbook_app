import '../core/index.dart';

class CommentRepository {
  static Future<ApiResponse<Comment>> addComment(
    int recipeId,
    Map<String, dynamic> data,
  ) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.addComment(recipeId, data, token);
  }

  static Future<ApiResponse<List<Comment>>> getComments(int recipeId) async {
    return await ApiService.getComments(
      recipeId,
      token: AuthService.currentToken,
    );
  }

  static Future<ApiResponse<Comment>> updateComment(
    int recipeId,
    int commentId,
    Map<String, dynamic> data,
  ) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.updateComment(recipeId, commentId, data, token);
  }

  static Future<ApiResponse<String>> deleteComment(
    int recipeId,
    int commentId,
  ) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.deleteComment(recipeId, commentId, token);
  }

  static Future<ApiResponse<Comment>> addReply(
    int recipeId,
    int parentCommentId,
    String replyText,
  ) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error(ErrorMessages.unauthorized);
    }
    return await ApiService.addComment(recipeId, {
      'comment': replyText,
      'parentCommentId': parentCommentId,
    }, token);
  }

  static Future<ApiResponse<List<Comment>>> getReplies(
    int recipeId,
    int parentCommentId,
  ) async {
    final result = await getComments(recipeId);
    if (result.success) {
      final replies = result.data!
          .where((comment) => comment.parentCommentId == parentCommentId)
          .toList();
      return ApiResponse.success(replies);
    }
    return result;
  }
}
