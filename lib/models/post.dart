class Post {
  final String id;
  final String title;
  final String author;
  final int minutesAgo;
  final int savedCount;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;

  const Post({
    required this.id,
    required this.title,
    required this.author,
    required this.minutesAgo,
    required this.savedCount,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
  });
}


