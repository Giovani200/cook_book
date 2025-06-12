import 'package:flutter/material.dart';
import 'package:cook_book/view/home/recipe_detail_view.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../common/app_colors.dart';

class CategoryRecipesView extends StatefulWidget {
  final String category;

  const CategoryRecipesView({Key? key, required this.category})
    : super(key: key);

  @override
  State<CategoryRecipesView> createState() => _CategoryRecipesViewState();
}

class _CategoryRecipesViewState extends State<CategoryRecipesView> {
  List<Map<String, dynamic>> _recipes = []; // CHANGEMENT: Map au lieu de Recipe
  List<Map<String, dynamic>> _filteredRecipes = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _searchController.addListener(_filterRecipes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipesWithAuthors = await RecipeService.instance
          .getRecipesByCategoryWithAuthors(widget.category);

      setState(() {
        _recipes = recipesWithAuthors;
        _filteredRecipes = List.from(recipesWithAuthors);
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des recettes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRecipes() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = List.from(_recipes);
      } else {
        _filteredRecipes =
            _recipes.where((recipeData) {
              final Recipe recipe = recipeData['recipe'];
              final name = recipe.name.toLowerCase();
              return name.contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.category,
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher une recette...",
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Contenu principal - liste des recettes ou messages
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : _filteredRecipes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune recette trouvée',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipeData = _filteredRecipes[index];
                        final Recipe recipe = recipeData['recipe'];
                        final String authorName = recipeData['authorName'];

                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          RecipeDetailView(recipe: recipe),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.primary,
                                        child: Text(
                                          authorName.isNotEmpty
                                              ? authorName[0].toUpperCase()
                                              : 'U',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Par $authorName',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    recipe.name,
                                    style: TextStyle(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    recipe.description,
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${recipe.prepTime} min prep',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.local_fire_department,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${recipe.cookingTime} min cuisson',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          await RecipeService.instance
                                              .likeRecipe(recipe.id);
                                          _loadRecipes();
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        '${recipe.likes}',
                                        style: TextStyle(fontFamily: 'Raleway'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
