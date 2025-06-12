import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/view/home/add_recipe_view.dart';
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
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  TextEditingController txtSearch = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();

    txtSearch.addListener(() {
      _filterRecipes();
    });
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await RecipeService.instance.getRecipesByCategory(
        widget.category,
      );
      setState(() {
        _recipes = recipes;
        _filteredRecipes = List.from(_recipes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  void _filterRecipes() {
    final query = txtSearch.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = List.from(_recipes);
      } else {
        _filteredRecipes =
            _recipes
                .where((recipe) => recipe.name.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipeView()),
              );

              // Actualiser la liste après l'ajout
              _loadRecipes();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Column(
                children: [
                  // Barre de recherche
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: txtSearch,
                        style: const TextStyle(fontFamily: 'Raleway'),
                        decoration: InputDecoration(
                          hintText: "Rechercher une recette",
                          hintStyle: TextStyle(
                            fontFamily: 'Raleway',
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Message si aucune recette
                  if (_filteredRecipes.isEmpty && _recipes.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Aucune recette disponible\nTouchez + pour en ajouter",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Message si aucun résultat de recherche
                  if (_filteredRecipes.isEmpty && _recipes.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Aucun résultat trouvé",
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Liste des recettes
                  if (_filteredRecipes.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                    recipe.imagePath != null
                                        ? Image.file(
                                          File(recipe.imagePath!),
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 70,
                                          height: 70,
                                          color: AppColors.secondary
                                              .withOpacity(0.3),
                                          child: const Icon(
                                            Icons.restaurant,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                              ),
                              title: Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.description.length > 50
                                        ? "${recipe.description.substring(0, 50)}..."
                                        : recipe.description,
                                    style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Cuisson: ${recipe.cookingTime} min",
                                        style: const TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Préparation: ${recipe.prepTime} min",
                                        style: const TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  await RecipeService.instance.likeRecipe(
                                    recipe.id,
                                  );
                                  _loadRecipes();
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: AppColors.primary,
                                ),
                              ),
                              onTap: () {
                                // Navigation vers la vue détaillée de la recette
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            RecipeDetailView(recipe: recipe),
                                  ),
                                );
                              },
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
