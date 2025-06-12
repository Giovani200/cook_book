// Service de gestion des recettes avec stockage MongoDB
import '../models/recipe_model.dart';
import 'mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RecipeService {
  // Instance unique (Singleton)
  static RecipeService? _instance;

  // Accesseur pour l'instance unique
  static RecipeService get instance {
    _instance ??= RecipeService._();
    return _instance!;
  }

  // Constructeur privé
  RecipeService._();

  // Enregistre une nouvelle recette dans MongoDB
  Future<void> saveRecipe(Recipe recipe) async {
    print('RecipeService: Sauvegarde recette ${recipe.name}');
    final success = await MongoDBService.instance.saveRecipe(recipe);
    if (!success) {
      throw Exception(
        'Échec de la sauvegarde de la recette en base de données',
      );
    }
  }

  // Récupère toutes les recettes depuis MongoDB
  Future<List<Recipe>> getAllRecipes() async {
    print('RecipeService: Récupération de toutes les recettes');
    return await MongoDBService.instance.getAllRecipes();
  }

  // Récupère les recettes d'une catégorie spécifique depuis MongoDB
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    print('RecipeService: Récupération recettes pour catégorie $category');
    return await MongoDBService.instance.getRecipesByCategory(category);
  }

  // Récupère les recettes les plus populaires depuis MongoDB
  Future<List<Recipe>> getMostPopularRecipes({int limit = 10}) async {
    print('RecipeService: Récupération recettes populaires (limite: $limit)');
    return await MongoDBService.instance.getMostPopularRecipes(limit: limit);
  }

  // Récupère les recettes les plus récentes depuis MongoDB
  Future<List<Recipe>> getRecentRecipes({int limit = 3}) async {
    print('RecipeService: Récupération recettes récentes (limite: $limit)');
    return await MongoDBService.instance.getRecentRecipes(limit: limit);
  }

  // Ajoute un "j'aime" à une recette dans MongoDB
  Future<void> likeRecipe(ObjectId? recipeId) async {
    print('RecipeService: Like pour recette $recipeId');
    final success = await MongoDBService.instance.likeRecipe(recipeId);
    if (!success) {
      throw Exception('Échec du like de la recette');
    }
  }

  // NOUVEAU: Récupère une recette avec le nom de l'auteur
  Future<Map<String, dynamic>> getRecipeWithAuthor(Recipe recipe) async {
    // CORRECTION: Gérer le cas où authorId est null
    if (recipe.authorId == null) {
      return {'recipe': recipe, 'authorName': 'Utilisateur inconnu'};
    }

    final author = await MongoDBService.instance.findUserById(recipe.authorId!);
    return {
      'recipe': recipe,
      'authorName': author?.name ?? 'Utilisateur inconnu',
    };
  }

  // NOUVEAU: Récupère toutes les recettes avec les noms d'auteurs
  Future<List<Map<String, dynamic>>> getAllRecipesWithAuthors() async {
    final recipes = await MongoDBService.instance.getAllRecipes();
    List<Map<String, dynamic>> recipesWithAuthors = [];

    for (Recipe recipe in recipes) {
      final recipeWithAuthor = await getRecipeWithAuthor(recipe);
      recipesWithAuthors.add(recipeWithAuthor);
    }

    return recipesWithAuthors;
  }

  // NOUVEAU: Récupère les recettes d'une catégorie avec les noms d'auteurs
  Future<List<Map<String, dynamic>>> getRecipesByCategoryWithAuthors(
    String category,
  ) async {
    final recipes = await MongoDBService.instance.getRecipesByCategory(
      category,
    );
    List<Map<String, dynamic>> recipesWithAuthors = [];

    for (Recipe recipe in recipes) {
      final recipeWithAuthor = await getRecipeWithAuthor(recipe);
      recipesWithAuthors.add(recipeWithAuthor);
    }

    return recipesWithAuthors;
  }
}
