import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../common/app_colors.dart';

class CategoryRecipesView extends StatefulWidget {
  final String category;

  const CategoryRecipesView({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryRecipesView> createState() => _CategoryRecipesViewState();
}

class _CategoryRecipesViewState extends State<CategoryRecipesView> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await RecipeService.instance.getRecipesByCategory(widget.category);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 80, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Aucune recette dans cette catégorie',
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
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                Icon(Icons.timer, size: 16, color: AppColors.primary),
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
                                Icon(Icons.local_fire_department, size: 16, color: AppColors.primary),
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
                                    await RecipeService.instance.likeRecipe(recipe.id);
                                    _loadRecipes();
                                  },
                                  icon: Icon(Icons.favorite, color: AppColors.primary),
                                ),
                                Text('${recipe.likes}', style: TextStyle(fontFamily: 'Raleway')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
