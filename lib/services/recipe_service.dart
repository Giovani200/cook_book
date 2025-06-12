// Service de gestion des recettes avec stockage MongoDB
import 'package:cook_book/models/recipe_model.dart';
import 'package:cook_book/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal();

  static RecipeService get instance => _instance;

  final String _collectionName = 'recipes';

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

  // Enregistre plusieurs recettes
  Future<int> saveRecipes(List<Recipe> recipes) async {
    try {
      return await MongoDBService.instance.bulkSaveRecipes(recipes);
    } catch (e) {
      print('Erreur lors de l\'enregistrement des recettes: $e');
      return 0;
    }
  }

  // Vérifie si des recettes existent déjà
  Future<bool> hasRecipes() async {
    try {
      final db = MongoDBService.instance.db;
      if (db == null) return false;

      final collection = db.collection(_collectionName);
      final count = await collection.count();
      return count > 0;
    } catch (e) {
      print('Erreur lors de la vérification des recettes: $e');
      return false;
    }
  }

  // Récupère toutes les recettes depuis MongoDB
  Future<List<Recipe>> getAllRecipes() async {
    List<Recipe> recipes = [];
    try {
      final db = MongoDBService.instance.db;
      if (db == null) return recipes;

      final collection = db.collection(_collectionName);
      final result = await collection.find().toList();
      recipes = result.map((data) => Recipe.fromMap(data)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des recettes: $e');
    }
    return recipes;
  }

  // Récupère les recettes d'une catégorie spécifique depuis MongoDB
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    List<Recipe> recipes = [];
    try {
      final db = MongoDBService.instance.db;
      if (db == null) return recipes;

      final collection = db.collection(_collectionName);
      final result =
          await collection.find(where.eq('category', category)).toList();
      recipes = result.map((data) => Recipe.fromMap(data)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des recettes par catégorie: $e');
    }
    return recipes;
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

  // NOUVEAU: Récupère les recettes d'un utilisateur spécifique
  Future<List<Recipe>> getRecipesByUserId(ObjectId userId) async {
    print('RecipeService: Récupération recettes pour utilisateur $userId');
    return await MongoDBService.instance.getRecipesByUserId(userId);
  }
}

// NOUVEAU: Récupère les recettes d'un utilisateur spécifique
Future<List<Recipe>> getRecipesByUserId(ObjectId userId) async {
  print('RecipeService: Récupération recettes pour utilisateur $userId');
  return await MongoDBService.instance.getRecipesByUserId(userId);
}
