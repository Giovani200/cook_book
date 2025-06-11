// Service de gestion des recettes avec stockage local
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class RecipeService {
  // Clé pour accéder aux recettes dans SharedPreferences
  static const String _recipesKey = 'recipes';
  // Instance unique (Singleton)
  static RecipeService? _instance;
  
  // Accesseur pour l'instance unique
  static RecipeService get instance {
    _instance ??= RecipeService._();
    return _instance!;
  }
  
  // Constructeur privé
  RecipeService._();

  // Enregistre une nouvelle recette
  Future<void> saveRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getAllRecipes();
    recipes.add(recipe);
    
    final recipesJson = recipes.map((r) => r.toJson()).toList();
    await prefs.setString(_recipesKey, jsonEncode(recipesJson));
  }

  // Récupère toutes les recettes stockées
  Future<List<Recipe>> getAllRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesString = prefs.getString(_recipesKey);
    
    if (recipesString == null) return [];
    
    final recipesJson = jsonDecode(recipesString) as List;
    return recipesJson.map((json) => Recipe.fromJson(json)).toList();
  }

  // Récupère les recettes d'une catégorie spécifique
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.category == category).toList();
  }

  // Récupère les recettes les plus populaires (les plus aimées)
  Future<List<Recipe>> getMostPopularRecipes({int limit = 10}) async {
    final recipes = await getAllRecipes();
    recipes.sort((a, b) => b.likes.compareTo(a.likes));
    return recipes.take(limit).toList();
  }

  // Récupère les recettes les plus récentes
  Future<List<Recipe>> getRecentRecipes({int limit = 3}) async {
    final recipes = await getAllRecipes();
    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recipes.take(limit).toList();
  }

  // Ajoute un "j'aime" à une recette
  Future<void> likeRecipe(String recipeId) async {
    final recipes = await getAllRecipes();
    final recipeIndex = recipes.indexWhere((r) => r.id == recipeId);
    if (recipeIndex != -1) {
      recipes[recipeIndex].likes++;
      await _saveAllRecipes(recipes);
    }
  }

  // Méthode privée pour sauvegarder la liste complète des recettes
  Future<void> _saveAllRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = recipes.map((r) => r.toJson()).toList();
    await prefs.setString(_recipesKey, jsonEncode(recipesJson));
  }
}
