// Ce service est désactivé car nous n'importons plus de recettes externes

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cook_book/services/recipe_service.dart';

class RecipeImporterService {
  static final RecipeImporterService _instance =
      RecipeImporterService._internal();
  factory RecipeImporterService() => _instance;
  RecipeImporterService._internal();

  static RecipeImporterService get instance => _instance;

  // Clé pour les préférences
  static const String _importCompletedKey = 'recipes_import_completed';

  // Ce service est désactivé
  Future<bool> importRecipes() async {
    print('Service d\'importation désactivé');
    return false;
  }
}
