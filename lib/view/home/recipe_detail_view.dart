import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../common/app_colors.dart';

class RecipeDetailView extends StatefulWidget {
  final Recipe recipe;
  final String? authorName;

  const RecipeDetailView({Key? key, required this.recipe, this.authorName})
    : super(key: key);

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  late Recipe _recipe;
  bool _isLiked = false;
  String _authorName = '';

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _loadAuthorName();
  }

  Future<void> _loadAuthorName() async {
    if (widget.authorName != null) {
      setState(() {
        _authorName = widget.authorName!;
      });
    } else {
      final recipeWithAuthor = await RecipeService.instance.getRecipeWithAuthor(
        _recipe,
      );
      setState(() {
        _authorName = recipeWithAuthor['authorName'];
      });
    }
  }

  Future<void> _toggleLike() async {
    try {
      if (_recipe.id != null) {
        await RecipeService.instance.likeRecipe(_recipe.id);
        setState(() {
          _recipe = Recipe(
            id: _recipe.id,
            name: _recipe.name,
            description: _recipe.description,
            preparation: _recipe.preparation,
            prepTime: _recipe.prepTime,
            cookingTime: _recipe.cookingTime,
            category: _recipe.category,
            imagePath: _recipe.imagePath,
            createdAt: _recipe.createdAt,
            authorId: _recipe.authorId,
            likes: _recipe.likes + 1,
          );
          _isLiked = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recette ajoutée aux favoris !'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout aux favoris'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _recipe.name,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _recipe.imagePath != null
                      ? Image.file(File(_recipe.imagePath!), fit: BoxFit.cover)
                      : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge catégorie et statistiques
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _recipe.category,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.favorite, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${_recipe.likes}',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Afficher l'auteur de la recette
                  Container(
                    width: double.infinity, // CORRECTION: Largeur fixe
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.secondary,
                          child: Text(
                            _authorName.isNotEmpty
                                ? _authorName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          // CORRECTION: Utiliser Expanded pour éviter le débordement
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recette de',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _authorName.isNotEmpty
                                    ? _authorName
                                    : 'Utilisateur inconnu',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow:
                                    TextOverflow
                                        .ellipsis, // CORRECTION: Gérer le débordement de texte
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Temps de préparation et cuisson
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeCard(
                          icon: Icons.timer,
                          title: 'Préparation',
                          time: '${_recipe.prepTime} min',
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeCard(
                          icon: Icons.local_fire_department,
                          title: 'Cuisson',
                          time: '${_recipe.cookingTime} min',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Description
                  _buildSectionTitle('Description'),
                  SizedBox(height: 12),
                  Text(
                    _recipe.description,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Préparation
                  _buildSectionTitle('Instructions'),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity, // CORRECTION: Largeur fixe
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _recipe.preparation,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Informations supplémentaires
                  Container(
                    width: double.infinity, // CORRECTION: Largeur fixe
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          // CORRECTION: Utiliser Expanded
                          child: Text(
                            'Ajoutée le ${_formatDate(_recipe.createdAt)}',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center, // CORRECTION: Centrer le texte
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center, // CORRECTION: Centrer le texte
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Playfair Display',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
