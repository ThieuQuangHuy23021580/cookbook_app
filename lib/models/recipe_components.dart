class Ingredient {
  final int id;
  final String name;
  final String? quantity;
  final String? unit;

  Ingredient({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, quantity: $quantity, unit: $unit)';
  }
}

class StepImage {
  final int id;
  final String imageUrl;
  final int? orderNumber;

  StepImage({
    required this.id,
    required this.imageUrl,
    this.orderNumber,
  });

  factory StepImage.fromJson(Map<String, dynamic> json) {
    return StepImage(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      orderNumber: json['orderNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'orderNumber': orderNumber,
    };
  }

  @override
  String toString() {
    return 'StepImage(id: $id, imageUrl: $imageUrl, orderNumber: $orderNumber)';
  }
}

class RecipeStep {
  final int id;
  final int stepNumber;
  final String title;
  final String? description;
  final List<StepImage> images;

  RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    this.description,
    this.images = const [],
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as int,
      stepNumber: json['stepNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => StepImage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'RecipeStep(id: $id, stepNumber: $stepNumber, title: $title)';
  }
}
