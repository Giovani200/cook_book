import 'dart:io'; // AJOUT: Import manquant pour File
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../models/user_model.dart';
import '../../services/recipe_service.dart';
import '../../services/user_session.dart';
import '../../common/app_colors.dart';
import 'recipe_detail_view.dart';
import 'add_recipe_view.dart';
import 'edit_profile_view.dart';
import 'user_recipes_view.dart';
import '../login/welcome_view.dart';

class ProfilView extends StatefulWidget {
  const ProfilView({Key? key}) : super(key: key);

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  User? _currentUser;
  List<Recipe> _userRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserSession.instance.getCurrentUser();
      if (user != null) {
        final allRecipes = await RecipeService.instance.getAllRecipes();

        // Filtrer les recettes de l'utilisateur connecté
        final userRecipes =
            allRecipes.where((recipe) => recipe.authorId == user.id).toList();

        // Trier par date (plus récentes en premier) et prendre les 3 dernières
        userRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentUserRecipes = userRecipes.take(3).toList();

        setState(() {
          _currentUser = user;
          _userRecipes = recentUserRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await UserSession.instance.clearUserSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Erreur de chargement du profil',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo de profil et informations
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Bouton retour
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                          ),
                          Spacer(),
                          // Bouton de déconnexion
                          GestureDetector(
                            onTap: _logout,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Photo de profil (grand cercle noir comme dans la maquette)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _currentUser!.name.isNotEmpty
                                ? _currentUser!.name[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Informations utilisateur
                      Row(
                        children: [
                          // Nom
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                _currentUser!.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Email
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currentUser!.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () async {
                                // CORRECTION: Navigation vers la page d'édition
                                final updatedUser = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditProfileView(
                                          user: _currentUser!,
                                        ),
                                  ),
                                );
                                if (updatedUser != null) {
                                  setState(() {
                                    _currentUser = updatedUser;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Modifier ✏️',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Section "Récemment ajouté"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Récemment ajouté',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // CORRECTION: Navigation vers toutes les recettes de l'utilisateur
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          UserRecipesView(user: _currentUser!),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'View all',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: () async {
                              // CORRECTION: Attendre le résultat de l'ajout
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddRecipeView(),
                                ),
                              );
                              if (result == true) {
                                _loadUserData(); // Recharger seulement si une recette a été ajoutée
                              }
                            },

                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Ajouter ✏️',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Liste des recettes récentes
                  if (_userRecipes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(40),
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune recette ajoutée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Commencez par ajouter votre première recette !',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children:
                          _userRecipes
                              .map((recipe) => _buildRecipeCard(recipe))
                              .toList(),
                    ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
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
          child: Icon(
            Icons
                .restaurant, // CHANGEMENT: Image universelle pour toutes les recettes
            color: AppColors.primary,
            size: 30,
          ),
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
              maxLines: 1,
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
                    authorName: _currentUser!.name,
                  ),
            ),
          );
        },
      ),
    );
  }
}
