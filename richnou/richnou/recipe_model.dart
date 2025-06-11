class Recipe {
  final String id;
  final String name;
  final String description;
  final String preparation;
  final String prepTime;
  final String cookingTime;
  final String category;
  final String? imagePath;
  final DateTime createdAt;
  int likes;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.preparation,
    required this.prepTime,
    required this.cookingTime,
    required this.category,
    this.imagePath,
    required this.createdAt,
    this.likes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'preparation': preparation,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'category': category,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      preparation: json['preparation'],
      prepTime: json['prepTime'],
      cookingTime: json['cookingTime'],
      category: json['category'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
    );
  }
}
