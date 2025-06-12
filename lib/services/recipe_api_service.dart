import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cook_book/models/recipe_model.dart';

class RecipeApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Singleton pattern
  static final RecipeApiService _instance = RecipeApiService._internal();
  factory RecipeApiService() => _instance;
  RecipeApiService._internal();

  // Récupérer les recettes par catégorie
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    List<Recipe> recipes = [];
    try {
      // 1. Obtenir les IDs des recettes de cette catégorie
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List? ?? [];

        // Limiter à 10 recettes par catégorie
        final limitedMeals = meals.take(10).toList();

        // 2. Pour chaque recette, obtenir les détails complets
        for (var meal in limitedMeals) {
          final recipe = await getRecipeDetails(meal['idMeal']);
          if (recipe != null) {
            recipes.add(recipe);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des recettes: $e');
    }

    return recipes;
  }

  // Rechercher des recettes par nom
  Future<List<Recipe>> searchRecipes(String query) async {
    List<Recipe> recipes = [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List? ?? [];

        // Limiter à 15 résultats pour des performances optimales
        final limitedMeals = meals.take(15).toList();

        for (var meal in limitedMeals) {
          final recipe = await getRecipeDetails(meal['idMeal']);
          if (recipe != null) {
            recipes.add(recipe);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche de recettes: $e');
    }

    return recipes;
  }

  // Obtenir une recette aléatoire
  Future<Recipe?> getRandomRecipe() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/random.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return _convertMealToRecipe(data['meals'][0]);
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération d\'une recette aléatoire: $e');
    }
    return null;
  }

  // Obtenir les détails d'une recette
  Future<Recipe?> getRecipeDetails(String mealId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$mealId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] == null || data['meals'].isEmpty) {
          return null;
        }

        final mealData = data['meals'][0];
        return _convertMealToRecipe(mealData);
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails de la recette: $e');
    }

    return null;
  }

  // Convertir les données de l'API en objet Recipe
  Recipe _convertMealToRecipe(Map<String, dynamic> mealData) {
    // Extraire les ingrédients qui ne sont pas vides
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      if (mealData['strIngredient$i'] != null &&
          mealData['strIngredient$i'].toString().trim().isNotEmpty) {
        String measure = mealData['strMeasure$i'] ?? '';
        String ingredient = mealData['strIngredient$i'];
        ingredients.add('$measure $ingredient'.trim());
      }
    }

    // Traiter les instructions
    String instructionsText = mealData['strInstructions'] ?? '';

    return Recipe(
      name: mealData['strMeal'] ?? 'Sans titre',
      description: mealData['strMeal'] ?? '',
      category: _mapCategory(mealData['strCategory'] ?? ''),
      imageUrl: mealData['strMealThumb'] ?? '',
      ingredients: ingredients,
      instructions: instructionsText,
      preparation: instructionsText,
      preparationTime: 30, // Valeur par défaut
      prepTime: 30, // Valeur par défaut
      cookingTime: 20, // Valeur par défaut
      servings: 4, // Valeur par défaut
      complexity:
          ingredients.length > 8
              ? 3
              : ingredients.length > 5
              ? 2
              : 1,
    );
  }

  // Mapper les catégories de l'API aux catégories de l'application
  String _mapCategory(String apiCategory) {
    final Map<String, String> categoryMap = {
      'Beef': 'Plats',
      'Chicken': 'Plats',
      'Dessert': 'Desserts',
      'Lamb': 'Plats',
      'Miscellaneous': 'Plats',
      'Pasta': 'Plats',
      'Pork': 'Plats',
      'Seafood': 'Plats',
      'Side': 'Entrées',
      'Starter': 'Entrées',
      'Vegan': 'Plats',
      'Vegetarian': 'Plats',
      'Breakfast': 'Entrées',
      'Goat': 'Plats',
    };

    return categoryMap[apiCategory] ?? 'Plats';
  }

  // Obtenir les catégories disponibles
  Future<List<String>> getCategories() async {
    List<String> categories = [];

    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categoriesData = data['categories'] as List? ?? [];

        categories =
            categoriesData
                .map((category) => category['strCategory'] as String)
                .toList();
      }
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
    }

    return categories;
  }
}
