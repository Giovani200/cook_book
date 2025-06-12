import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../common/app_colors.dart';
import '../../services/user_session.dart';
import 'category_recipes_view.dart';
import 'recipe_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Map<String, dynamic>> _recentRecipes =
      []; // CHANGEMENT: Map au lieu de Recipe
  List<Map<String, dynamic>> _popularRecipes =
      []; // CHANGEMENT: Map au lieu de Recipe
  bool _isLoading = true;
  String _userName = ""; // Nom de l'utilisateur connecté

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Entrées',
      'icon': Icons.restaurant,
      'color': AppColors.primary,
      'image': 'assets/img/entrees.png',
    },
    {
      'name': 'Plats',
      'icon': Icons.dinner_dining,
      'color': AppColors.secondary,
      'image': 'assets/img/plats.png',
    },
    {
      'name': 'Desserts',
      'icon': Icons.cake,
      'color': AppColors.accent,
      'image': 'assets/img/desserts.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserSession.instance.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final recentRecipes = await RecipeService.instance.getAllRecipes();
      final popularRecipes = await RecipeService.instance.getAllRecipes();

      // Conversion en Map avec auteurs
      List<Map<String, dynamic>> recentWithAuthors = [];
      List<Map<String, dynamic>> popularWithAuthors = [];

      // Récupérer les 3 plus récentes
      final sortedRecent = List<Recipe>.from(recentRecipes);
      sortedRecent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      for (int i = 0; i < 3 && i < sortedRecent.length; i++) {
        final recipeWithAuthor = await RecipeService.instance
            .getRecipeWithAuthor(sortedRecent[i]);
        recentWithAuthors.add(recipeWithAuthor);
      }

      // Récupérer les 5 plus populaires
      final sortedPopular = List<Recipe>.from(popularRecipes);
      sortedPopular.sort((a, b) => b.likes.compareTo(a.likes));
      for (int i = 0; i < 5 && i < sortedPopular.length; i++) {
        final recipeWithAuthor = await RecipeService.instance
            .getRecipeWithAuthor(sortedPopular[i]);
        popularWithAuthors.add(recipeWithAuthor);
      }

      setState(() {
        _recentRecipes = recentWithAuthors;
        _popularRecipes = popularWithAuthors;
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header avec salutation
                        _buildHeader(),
                        const SizedBox(height: 30),

                        // Recettes récemment ajoutées
                        if (_recentRecipes.isNotEmpty) ...[
                          _buildSectionTitle("Recettes récemment ajoutées"),
                          const SizedBox(height: 15),
                          _buildRecentRecipesSection(),
                          const SizedBox(height: 30),
                        ],

                        // Section Catégories
                        _buildSectionTitle("Catégories"),
                        const SizedBox(height: 15),
                        _buildCategoriesSection(),
                        const SizedBox(height: 30),

                        // Recettes populaires
                        if (_popularRecipes.isNotEmpty) ...[
                          _buildSectionTitle("Recettes populaires"),
                          const SizedBox(height: 15),
                          _buildPopularRecipesSection(),
                        ] else ...[
                          _buildEmptyState(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bonjour${_userName.isNotEmpty ? ' $_userName' : ''}!",
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                "Que cuisinons-nous aujourd'hui ?",
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child:
                  _userName.isNotEmpty
                      ? Text(
                        _userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRecentRecipesSection() {
    return SizedBox(
      height: 220, // Augmenté pour inclure l'auteur
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: _recentRecipes.length,
        itemBuilder: (context, index) {
          final recipeData = _recentRecipes[index];
          final Recipe recipe = recipeData['recipe'];
          final String authorName = recipeData['authorName'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailView(recipe: recipe),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontFamily: 'Playfair Display',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Text(
                            authorName.isNotEmpty
                                ? authorName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Par $authorName',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recipe.description,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "${recipe.prepTime} min",
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.category,
                            style: const TextStyle(
                              fontFamily: 'Raleway',
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }

  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          CategoryRecipesView(category: category['name']),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: category['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'],
                      size: 30,
                      color: category['color'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularRecipesSection() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _popularRecipes.length,
      itemBuilder: (context, index) {
        final recipeData = _popularRecipes[index];
        final Recipe recipe = recipeData['recipe'];
        final String authorName = recipeData['authorName'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailView(recipe: recipe),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: Colors.white, size: 28),
              ),
              title: Text(
                recipe.name,
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Par $authorName',
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    recipe.category,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        "${recipe.prepTime} min",
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
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: AppColors.primary, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.likes}',
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucune recette disponible",
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Commencez par ajouter votre première recette !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
