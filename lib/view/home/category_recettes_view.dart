import 'dart:io';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/view/home/add_recipe_view.dart';
import 'package:flutter/material.dart';

class CategoryRecipesView extends StatefulWidget {
  final String category;
  
  const CategoryRecipesView({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryRecipesView> createState() => _CategoryRecipesViewState();
}

class _CategoryRecipesViewState extends State<CategoryRecipesView> {
  late List<Recipe> _recipes;
  TextEditingController txtSearch = TextEditingController();
  List<Recipe> _filteredRecipes = [];
  
  @override
  void initState() {
    super.initState();
    _recipes = RecipeService().getRecipesByCategory(widget.category);
    _filteredRecipes = List.from(_recipes);
    
    txtSearch.addListener(() {
      _filterRecipes();
    });
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
        _filteredRecipes = _recipes
            .where((recipe) => recipe.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: TColor.primaryText),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipeView(),
                ),
              );
              
              // Actualiser la liste après l'ajout
              setState(() {
                _recipes = RecipeService().getRecipesByCategory(widget.category);
                _filterRecipes();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: txtSearch,
                decoration: InputDecoration(
                  hintText: "Rechercher une recette",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Aucune recette disponible\nTouchez + pour en ajouter",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[500],
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
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Aucun résultat trouvé",
                      style: TextStyle(
                        color: Colors.grey[500],
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: recipe.imagePath != null
                            ? Image.file(
                                File(recipe.imagePath!),
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[600],
                                ),
                              ),
                      ),
                      title: Text(
                        recipe.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.description.length > 50
                                ? "${recipe.description.substring(0, 50)}..."
                                : recipe.description,
                            style: TextStyle(color: TColor.secondaryText),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: TColor.primaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Cuisson: ${recipe.cookingTime} min",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TColor.secondaryText,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: TColor.primaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Préparation: ${recipe.prepTime} min",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TColor.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigation vers la vue détaillée de la recette
                        // À implémenter plus tard
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