import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_api_service.dart';
import '../../services/recipe_service.dart';
import '../../common/app_colors.dart';

class ApiRecipesView extends StatefulWidget {
  const ApiRecipesView({Key? key}) : super(key: key);

  @override
  State<ApiRecipesView> createState() => _ApiRecipesViewState();
}

class _ApiRecipesViewState extends State<ApiRecipesView> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isImporting = false;
  String _errorMessage = '';
  final RecipeApiService _apiService = RecipeApiService();

  @override
  void initState() {
    super.initState();
    _loadRandomRecipe();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRandomRecipe() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final recipe = await _apiService.getRandomRecipe();
      setState(() {
        _recipes = recipe != null ? [recipe] : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchRecipes() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final recipes = await _apiService.searchRecipes(query);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importRecipe(Recipe recipe) async {
    setState(() {
      _isImporting = true;
    });

    try {
      await RecipeService.instance.saveRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recette importée avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'importation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Recettes externes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRandomRecipe,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher des recettes...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (_) => _searchRecipes(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchRecipes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),

          // Message d'information
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Recherchez et importez des recettes depuis notre base de données externe.",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),

          const SizedBox(height: 10),

          // Contenu principal
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : _recipes.isEmpty
                    ? const Center(child: Text("Aucune recette trouvée"))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child:
                recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                    ? Image.network(
                      recipe.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                        );
                      },
                    )
                    : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 50),
                    ),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Badge "API"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "API",
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        recipe.category,
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Titre
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Ingrédients (titre)
                const Text(
                  "Ingrédients:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),

                // Liste d'ingrédients (limitée à 5)
                ...recipe.ingredients.take(5).map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  );
                }).toList(),

                // Indication s'il y a plus d'ingrédients
                if (recipe.ingredients.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "et ${recipe.ingredients.length - 5} de plus...",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bouton d'importation
                    ElevatedButton.icon(
                      onPressed:
                          _isImporting ? null : () => _importRecipe(recipe),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon:
                          _isImporting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.download),
                      label: const Text("Importer"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
