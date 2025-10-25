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
  final bool isLiked;
  final bool isBookmarked;
  final int likesCount;
  final int bookmarksCount;
  final double averageRating;
  final int ratingsCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.servings,
    this.cookingTime,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.ingredients,
    required this.steps,
    required this.isLiked,
    required this.isBookmarked,
    required this.likesCount,
    required this.bookmarksCount,
    required this.averageRating,
    required this.ratingsCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      servings: json['servings'],
      cookingTime: json['cookingTime'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      steps: (json['steps'] as List)
          .map((s) => RecipeStep.fromJson(s))
          .toList(),
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      likesCount: json['likesCount'] ?? 0,
      bookmarksCount: json['bookmarksCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Ingredient {
  final int id;
  final String name;
  final String quantity;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}

class RecipeStep {
  final int id;
  final int stepNumber;
  final String title;
  final String description;
  final List<StepImage> images;

  RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.images,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'],
      stepNumber: json['stepNumber'],
      title: json['title'],
      description: json['description'],
      images: (json['images'] as List)
          .map((img) => StepImage.fromJson(img))
          .toList(),
    );
  }
}

class StepImage {
  final int id;
  final String imageUrl;
  final int orderNumber;

  StepImage({
    required this.id,
    required this.imageUrl,
    required this.orderNumber,
  });

  factory StepImage.fromJson(Map<String, dynamic> json) {
    return StepImage(
      id: json['id'],
      imageUrl: json['imageUrl'],
      orderNumber: json['orderNumber'],
    );
  }
}