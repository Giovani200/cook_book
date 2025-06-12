import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../models/user_model.dart';
import '../../services/recipe_service.dart';
import '../../services/user_session.dart';
import '../../services/mongodb_service.dart';
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
        print('👤 Utilisateur connecté: ${user.name} (ID: ${user.id})');

        // CORRECTION: Si l'utilisateur n'a pas d'ID, le récupérer depuis MongoDB
        User finalUser = user;
        if (user.id == null) {
          print('⚠️ Utilisateur sans ID, récupération depuis MongoDB...');
          final userFromDB = await MongoDBService.instance.findUserByEmail(
            user.email,
          );
          if (userFromDB?.id != null) {
            finalUser = userFromDB!;
            // Mettre à jour la session
            await UserSession.instance.saveUserSession(finalUser);
            print('✅ ID récupéré: ${finalUser.id}');
          }
        }

        List<Recipe> userRecipes = [];

        if (finalUser.id != null) {
          // Utiliser la requête directe par userId
          userRecipes = await RecipeService.instance.getRecipesByUserId(
            finalUser.id!,
          );
          print(
            '📖 Utilisation de getRecipesByUserId avec ID: ${finalUser.id}',
          );
        } else {
          print('⚠️ Impossible de récupérer les recettes sans ID utilisateur');
          userRecipes = [];
        }

        print(
          '👨‍🍳 Recettes de l\'utilisateur trouvées: ${userRecipes.length}',
        );

        // Trier par date (plus récentes en premier) et prendre les 3 dernières
        userRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentUserRecipes = userRecipes.take(3).toList();

        setState(() {
          _currentUser = finalUser;
          _userRecipes = recentUserRecipes;
          _isLoading = false;
        });
      } else {
        print('❌ Aucun utilisateur connecté trouvé');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données utilisateur: $e');
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
        body: const Center(
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
              const Icon(Icons.error, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
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
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Bouton retour et déconnexion
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _logout,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Photo de profil
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _currentUser!.name.isNotEmpty
                                ? _currentUser!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Nom utilisateur
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          _currentUser!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Email
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentUser!.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
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

            const SizedBox(height: 30),

            // Section "Récemment ajouté"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
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
                              padding: const EdgeInsets.symmetric(
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
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () async {
                              // Navigation vers l'ajout de recette (pas l'importation)
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddRecipeView(),
                                ),
                              );
                              if (result == true) {
                                _loadUserData();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Ajouter ✏️', // Titre modifié pour éviter la confusion avec l'importation
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

                  const SizedBox(height: 20),

                  // Liste des recettes récentes
                  if (_userRecipes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
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
                          const SizedBox(height: 16),
                          Text(
                            'Aucune recette ajoutée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.restaurant,
            color: AppColors.primary,
            size: 30,
          ),
        ),
        title: Text(
          recipe.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                const Spacer(),
                const Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 4),
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
