import 'recipe_components.dart';

class Recipe {
  final int id;
  final String title;
  final String? imageUrl;
  final int servings;
  final int? cookingTime;
  final int userId;
  final String userName;
  final String? userAvatar;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final int likesCount;
  final int bookmarksCount;
  final double averageRating;
  final int ratingsCount;
  final int commentsCount;
  
  final bool isLikedByCurrentUser;
  final bool isBookmarkedByCurrentUser;
  final int? userRating;

  Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.servings,
    this.cookingTime,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.ingredients = const [],
    this.steps = const [],
    this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.bookmarksCount = 0,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
    this.commentsCount = 0,
    this.isLikedByCurrentUser = false,
    this.isBookmarkedByCurrentUser = false,
    this.userRating,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      servings: json['servings'] as int,
      cookingTime: json['cookingTime'] as int?,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      likesCount: json['likesCount'] as int? ?? 0,
      bookmarksCount: json['bookmarksCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: json['ratingsCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
      isBookmarkedByCurrentUser: json['isBookmarkedByCurrentUser'] as bool? ?? false,
      userRating: json['userRating'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'servings': servings,
      'cookingTime': cookingTime,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likesCount': likesCount,
      'bookmarksCount': bookmarksCount,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'commentsCount': commentsCount,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'isBookmarkedByCurrentUser': isBookmarkedByCurrentUser,
      'userRating': userRating,
    };
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? imageUrl,
    int? servings,
    int? cookingTime,
    int? userId,
    String? userName,
    String? userAvatar,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? bookmarksCount,
    double? averageRating,
    int? ratingsCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
    bool? isBookmarkedByCurrentUser,
    int? userRating,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      servings: servings ?? this.servings,
      cookingTime: cookingTime ?? this.cookingTime,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isBookmarkedByCurrentUser: isBookmarkedByCurrentUser ?? this.isBookmarkedByCurrentUser,
      userRating: userRating ?? this.userRating,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, servings: $servings, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
