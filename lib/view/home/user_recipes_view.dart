import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../models/user_model.dart';
import '../../services/recipe_service.dart';
import '../../common/app_colors.dart';
import 'recipe_detail_view.dart';
import 'add_recipe_view.dart';

class UserRecipesView extends StatefulWidget {
  final User user;

  const UserRecipesView({Key? key, required this.user}) : super(key: key);

  @override
  State<UserRecipesView> createState() => _UserRecipesViewState();
}

class _UserRecipesViewState extends State<UserRecipesView> {
  List<Recipe> _userRecipes = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadUserRecipes();
    _searchController.addListener(_filterRecipes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRecipes() async {
    try {
      final allRecipes = await RecipeService.instance.getAllRecipes();

      // Filtrer les recettes de l'utilisateur
      final userRecipes =
          allRecipes
              .where((recipe) => recipe.authorId == widget.user.id)
              .toList();

      // Trier par date (plus récentes en premier)
      userRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _userRecipes = userRecipes;
        _filteredRecipes = List.from(userRecipes);
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
        _filteredRecipes = List.from(_userRecipes);
      } else {
        _filteredRecipes =
            _userRecipes.where((recipe) {
              return recipe.name.toLowerCase().contains(query) ||
                  recipe.description.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Mes recettes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipeView()),
              );
              if (result == true) {
                _loadUserRecipes(); // Recharger la liste
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                  hintText: "Rechercher dans mes recettes...",
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Statistiques
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_userRecipes.length}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Recettes',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_userRecipes.fold(0, (sum, recipe) => sum + recipe.likes)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Likes totaux',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Liste des recettes
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
                            Icons.restaurant_menu,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _userRecipes.isEmpty
                                ? 'Aucune recette ajoutée'
                                : 'Aucun résultat trouvé',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_userRecipes.isEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              'Touchez + pour ajouter votre première recette !',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _filteredRecipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.restaurant, color: AppColors.primary, size: 30),
        ),
        title: Text(
          recipe.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${recipe.prepTime}min prep',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Spacer(),
                Icon(Icons.favorite, size: 16, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  '${recipe.likes}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RecipeDetailView(
                    recipe: recipe,
                    authorName: widget.user.name,
                  ),
            ),
          );
        },
      ),
    );
  }
}
