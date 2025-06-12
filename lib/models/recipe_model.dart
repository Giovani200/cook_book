import 'package:mongo_dart/mongo_dart.dart';

class Recipe {
  final ObjectId? id;
  final String name;
  final String description;
  final String preparation;
  final String prepTime;
  final String cookingTime;
  final String category;
  final String? imagePath;
  final DateTime createdAt;
  final ObjectId?
  authorId; // CHANGEMENT: Rendre nullable pour gérer les anciennes recettes
  int likes;

  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.preparation,
    required this.prepTime,
    required this.cookingTime,
    required this.category,
    this.imagePath,
    required this.createdAt,
    this.authorId, // CHANGEMENT: Rendre optionnel
    this.likes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'preparation': preparation,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'category': category,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId, // Peut être null
      'likes': likes,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // CORRECTION: Gérer authorId null ou manquant
    ObjectId? parseAuthorId() {
      try {
        final authorIdValue = json['authorId'];
        if (authorIdValue == null) {
          print('⚠️ AuthorId null pour recette: ${json['name']}');
          return null;
        }
        if (authorIdValue is ObjectId) {
          return authorIdValue;
        }
        if (authorIdValue is String && authorIdValue.isNotEmpty) {
          return ObjectId.parse(authorIdValue);
        }
        return null;
      } catch (e) {
        print('⚠️ Erreur parsing authorId: $e');
        return null;
      }
    }

    return Recipe(
      id:
          json['_id'] is ObjectId
              ? json['_id']
              : json['_id'] != null
              ? ObjectId.parse(json['_id'].toString())
              : null,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      preparation: json['preparation'] ?? '',
      prepTime: json['prepTime'] ?? '0',
      cookingTime: json['cookingTime'] ?? '0',
      category: json['category'] ?? 'Autre',
      imagePath: json['imagePath'],
      createdAt:
          json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(
                json['createdAt'] ?? DateTime.now().toIso8601String(),
              ),
      authorId:
          parseAuthorId(), // CORRECTION: Utiliser la fonction de parsing sécurisée
      likes: json['likes'] ?? 0,
    );
  }
}
