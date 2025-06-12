import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert'; // Ajout de cet import pour jsonDecode

class Recipe {
  final ObjectId? id;
  final String name;
  final String description;
  final List<String> ingredients;
  final String instructions;
  final String preparation;
  final int? preparationTime;
  final int prepTime;
  final int cookingTime;
  final int servings;
  final String category;
  final String? imagePath;
  final String? imageUrl;
  final int complexity; // 1-3
  final DateTime createdAt; // Date de création
  final ObjectId? authorId; // ID de l'utilisateur créateur
  final int likes; // Nombre de likes

  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.preparation,
    this.preparationTime,
    int? prepTime,
    int? cookingTime,
    required this.servings,
    required this.category,
    this.imagePath,
    this.imageUrl,
    this.complexity = 2,
    DateTime? createdAt,
    this.authorId,
    int? likes,
  }) : this.prepTime = prepTime ?? 30,
       this.cookingTime = cookingTime ?? 20,
       this.createdAt = createdAt ?? DateTime.now(),
       this.likes = likes ?? 0;

  // Factory pour les recettes venant de MongoDB avec gestion d'erreurs améliorée
  factory Recipe.fromMap(Map<String, dynamic> map) {
    try {
      return Recipe(
        id: map['_id'],
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        ingredients: _parseStringList(map['ingredients']),
        instructions: map['instructions'] ?? '',
        preparation: map['preparation'] ?? '',
        preparationTime: _parseIntValue(map['preparationTime']),
        prepTime: _parseIntValue(map['prepTime']),
        cookingTime: _parseIntValue(map['cookingTime']),
        servings: _parseIntValue(map['servings']) ?? 4,
        category: map['category'] ?? "Non catégorisé",
        imagePath: map['imagePath'],
        imageUrl: map['imageUrl'],
        complexity: _parseIntValue(map['complexity']) ?? 2,
        createdAt: _parseDateTime(map['createdAt']),
        authorId: _parseObjectId(map['authorId']),
        likes: _parseIntValue(map['likes']) ?? 0,
      );
    } catch (e) {
      print('Erreur lors de la conversion d\'une recette: $e');
      print('Données problématiques: $map');

      // Créer une recette par défaut en cas d'erreur
      return Recipe(
        name: map['name'] ?? 'Recette sans nom',
        description: map['description'] ?? 'Description non disponible',
        ingredients: _parseStringList(map['ingredients']),
        instructions: map['instructions'] ?? 'Instructions non disponibles',
        preparation: map['preparation'] ?? 'Préparation non disponible',
        servings: 4,
        category: map['category'] ?? "Non catégorisé",
      );
    }
  }

  // Pour la compatibilité avec MongoDB
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'preparation': preparation,
      'preparationTime': preparationTime,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'servings': servings,
      'category': category,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'complexity': complexity,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId,
      'likes': likes,
    };
  }

  // Alias pour assurer la compatibilité
  Map<String, dynamic> toJson() => toMap();

  // Alias pour assurer la compatibilité
  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe.fromMap(json);

  // Méthodes utilitaires pour la conversion des types améliorées
  static int? _parseIntValue(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        try {
          // Essayer de convertir via double (ex: "12.0" → 12)
          return double.parse(value).toInt();
        } catch (e2) {
          print(
            'Erreur lors de la conversion en int: "$value" (${value.runtimeType})',
          );
          return null;
        }
      }
    }

    print(
      'Type non pris en charge pour conversion en int: ${value.runtimeType}',
    );
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      // Tenter de parser une chaîne JSON
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (e) {
        // Si ce n'est pas du JSON, considérer comme une seule valeur
        return [value];
      }
    }

    return [];
  }

  // Méthode d'aide pour parser les dates
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Erreur lors de la conversion en DateTime: $value');
      }
    }

    return DateTime.now();
  }

  // Méthode d'aide pour parser les ObjectId
  static ObjectId? _parseObjectId(dynamic value) {
    if (value == null) return null;

    if (value is ObjectId) return value;

    if (value is String) {
      try {
        return ObjectId.fromHexString(value);
      } catch (e) {
        print('Erreur lors de la conversion en ObjectId: $value');
      }
    }

    return null;
  }
}
