class Recipe {
  final int id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final int cookingTime;
  final int servings;
  final String difficulty;
  final String category;
  final String image;
  final int readyInMinutes;
  final double rating;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.category,
    required this.image,
    required this.readyInMinutes,
    required this.rating,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      imageUrl: json['imageUrl'],
      cookingTime: json['cookingTime'],
      servings: json['servings'],
      difficulty: json['difficulty'],
      category: json['category'],
      image: json['image'],
      readyInMinutes: json['readyInMinutes'],
      rating: json['spoonacularScore']?.toDouble() ?? 0.0,
    );
  }
}
