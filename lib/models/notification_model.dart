import '../constants/app_constants.dart';

class AppNotification {
  final int id;
  final int userId;
  final String type; // LIKE, COMMENT, RATING, REPLY, BOOKMARK
  final int? actorId;
  final String? actorName;
  final String? actorAvatar;
  final int? recipeId;
  final String? recipeTitle;
  final String? recipeImage;
  final int? commentId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.recipeId,
    this.recipeTitle,
    this.recipeImage,
    this.commentId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Fix localhost URLs for images
    final rawActorAvatar = json['actorAvatar'] as String?;
    final fixedActorAvatar = rawActorAvatar != null && rawActorAvatar.isNotEmpty
        ? ApiConfig.fixImageUrl(rawActorAvatar)
        : null;

    final rawRecipeImage = json['recipeImage'] as String?;
    final fixedRecipeImage = rawRecipeImage != null && rawRecipeImage.isNotEmpty
        ? ApiConfig.fixImageUrl(rawRecipeImage)
        : null;

    return AppNotification(
      id: json['id'] as int,
      userId: json['userId'] as int,
      type: json['type'] as String,
      actorId: json['actorId'] as int?,
      actorName: json['actorName'] as String?,
      actorAvatar: fixedActorAvatar,
      recipeId: json['recipeId'] as int?,
      recipeTitle: json['recipeTitle'] as String?,
      recipeImage: fixedRecipeImage,
      commentId: json['commentId'] as int?,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).subtract(const Duration(hours: 7))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'actorId': actorId,
      'actorName': actorName,
      'actorAvatar': actorAvatar,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'recipeImage': recipeImage,
      'commentId': commentId,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper to get icon for notification type
  String getIconEmoji() {
    switch (type) {
      case 'LIKE':
        return '❤️';
      case 'COMMENT':
        return '💬';
      case 'RATING':
        return '⭐';
      case 'REPLY':
        return '↩️';
      case 'BOOKMARK':
        return '🔖';
      default:
        return '🔔';
    }
  }
  
  AppNotification copyWith({
    int? id,
    int? userId,
    String? type,
    int? actorId,
    String? actorName,
    String? actorAvatar,
    int? recipeId,
    String? recipeTitle,
    String? recipeImage,
    int? commentId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeImage: recipeImage ?? this.recipeImage,
      commentId: commentId ?? this.commentId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

